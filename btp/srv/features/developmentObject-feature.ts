import {
  DevelopmentObject,
  Import,
  ScoringRecord
} from '#cds-models/kernseife/db';
import { db, entities, log, Transaction } from '@sap/cds';
import { text } from 'node:stream/consumers';
import papa from 'papaparse';

const LOG = log('DevelopmentObjectFeature');


export const getDevelopmentObjectCount = async () => {
  const result = await SELECT.from(entities.DevelopmentObjects).columns(
    'IFNULL(COUNT( * ),0) as count'
  );
  return result[0]['count'];
};


export const getTotalScore = async () => {
  const result = await SELECT.from(entities.DevelopmentObjects).columns(
    'IFNULL(SUM( score ), 0) as score'
  );
  return result[0]['score'];
};

export const determineNamespace = (developmentObject) => {
  switch (developmentObject.objectName?.charAt(0)) {
    case '/':
      return '/' + developmentObject.objectName.split('/')[1] + '/';
    case 'Z':
    case 'Y':
      return developmentObject.objectName?.charAt(0);
    default:
      return undefined;
  }
};

export const calculateScoreByRef = async (ref) => {
  // read Development Object
  const developmentObject = await SELECT.one.from(ref);

  // Get Latest Scoring Run
  const scoringRecordList = await SELECT.from(entities.ScoringRecords)
    .columns(
      'itemId',
      'rating_code',
      'classification.rating.code as rating_code_dyn',
      'classification.rating.score as score'
    )
    .where({
      import_ID: developmentObject.latestScoringImportId,
      objectType: developmentObject.objectType,
      objectName: developmentObject.objectName,
      devClass: developmentObject.devClass,
      systemId: developmentObject.systemId
    });
  LOG.info('scoringRecordList', { scoringRecordList: scoringRecordList });
  const score = scoringRecordList.reduce((sum, row) => {
    return sum + row.score;
  }, 0);
  developmentObject.score = score || 0;
  LOG.info('Development Object Score', {
    score: developmentObject.score
  });
  // Update Development Object
  await UPSERT.into(entities.DevelopmentObjects).entries([developmentObject]);
  // Update Scoring Findings
  for (const scoringRecord of scoringRecordList) {
    if (scoringRecord.rating_code_dyn !== scoringRecord.rating_code) {
      //LOG.info("Updating Scoring Finding", { name: developmentObject.objectName, old: scoringRecord.rating_code, new: scoringRecord.rating_code_dyn });
      await UPDATE.entity(entities.ScoringRecords)
        .with({
          rating_code: scoringRecord.rating_code_dyn
        })
        .where({
          import_ID: developmentObject.latestScoringImportId,
          itemId: scoringRecord.itemId
        });
    }
  }

  return developmentObject;
};


export const calculateNamespaces = async () => {
  if (db.kind != 'sqlite') {
    await db.run(
      "UPDATE kernseife_db_DEVELOPMENTOBJECTS SET NAMESPACE = CASE SUBSTRING(OBJECTNAME,1,1) WHEN 'Z' THEN 'Z' WHEN 'Y' THEN 'Y' WHEN '/' THEN SUBSTR_REGEXPR('(^/.*/).+$' IN OBJECTNAME GROUP 1) ELSE ''  END"
    );
  }
};

export const calculateScores = async () => {
  // we could put all 3 operations into once Statement, but this is easier to debug

  // First update Scoring Records with latest classification ratings in case those changed
  await db.run(
    'UPDATE kernseife_db_SCORINGRECORDS as s SET rating_code = (SELECT c.rating_code FROM kernseife_db_CLASSIFICATIONS as c WHERE c.objectType = s.refObjectType AND c.objectName = s.refObjectName)'
  );

  // Calculate Score for all Development Objects
  await db.run(
    'UPDATE kernseife_db_DEVELOPMENTOBJECTS as d SET score = IFNULL((' +
      'SELECT IFNULL(sum(r.score),0) AS sum_score ' +
      'FROM kernseife_db_SCORINGRECORDS as f ' +
      'INNER JOIN kernseife_db_RATINGS as r ON r.code = f.rating_code ' +
      'WHERE f.objectType = d.objectType AND f.objectName = d.objectName AND f.devClass = d.devClass AND f.systemId = d.systemId AND d.latestScoringImportId = f.import_ID ' +
      'GROUP BY f.import_ID, f.objectType, f.objectName, f.devClass, f.systemId),0)'
  );

  // Set Score to 0 in case there are no findings
  await db.run(
    "UPDATE kernseife_db_DEVELOPMENTOBJECTS as d SET score = 0 WHERE score IS NULL AND latestScoringImportId IS NOT NULL AND latestScoringImportId != ''"
  );

  // Calculate Name spaces
  await calculateNamespaces();
  // Calculate Reference Count & Score
  await db.run(
    'UPDATE kernseife_db_CLASSIFICATIONS as c SET ' +
    'referenceCount =  IFNULL((SELECT SUM(count) FROM kernseife_db_DevelopmentObjectsAggregated as d WHERE d.refObjectType = c.objectType AND d.refObjectName = c.objectName),0),' +
    'totalScore = IFNULL((SELECT SUM(score) FROM kernseife_db_DevelopmentObjectsAggregated as d WHERE d.refObjectType = c.objectType AND d.refObjectName = c.objectName),0)'
  );
};

const calculateScore = async (developmentObject: DevelopmentObject) => {
  const result = await SELECT.from(entities.ScoringRecords)
    .columns(`sum(rating.score) as score`)
    .where({
      import_ID: developmentObject.latestScoringImportId,
      objectType: developmentObject.objectType,
      objectName: developmentObject.objectName,
      devClass: developmentObject.devClass
    })
    .groupBy('objectType', 'objectName', 'devClass');
  return result[0]?.score || 0;
};

export const getDevelopmentObjectIdentifier = (
  object: ScoringRecord | DevelopmentObject
) => {
  return (
    (object.systemId || '') +
    (object.devClass || '') +
    (object.objectType || '') +
    (object.objectName || '')
  );
};

export const getDevelopmentObjectMap = async () => {
  const developmentObjectDB = await SELECT.from(entities.DevelopmentObjects);
  return developmentObjectDB.reduce((map, developmentObject) => {
    return map.set(
      getDevelopmentObjectIdentifier(developmentObject),
      developmentObject
    );
  }, new Map<string, DevelopmentObject>()) as Map<string, DevelopmentObject>;
};

export const importScoring = async (
  scoringImport: Import,
  tx?: Transaction,
  updateProgress?: (progress: number) => Promise<void>
) => {
  if (!scoringImport.file) throw new Error('File broken');

  const csv = await text(scoringImport.file);
  const result = papa.parse<any>(csv, {
    header: true,
    skipEmptyLines: true
  });
  const itemIdSet = new Set();

  const scoringRecordList = result.data
    .map((finding) => {
      if (itemIdSet.has(finding.itemId || finding.ITEMID || finding.itemID)) {
        // duplicate!
        throw new Error(
          'Duplicate ItemId ' +
            (finding.itemId || finding.ITEMID || finding.itemID)
        );
      }

      itemIdSet.add(finding.itemId || finding.ITEMID || finding.itemID);
      return {
        // Map Attribues
        import_ID: scoringImport.ID,
        systemId: scoringImport.systemId,
        itemId: finding.itemId || finding.ITEMID || finding.itemID,
        objectType: finding.objectType || finding.OBJECTTYPE,
        objectName: finding.objectName || finding.OBJECTNAME,
        devClass: finding.devClass || finding.DEVCLASS,
        refObjectType: finding.refObjectType || finding.REFOBJECTTYPE,
        refObjectName: finding.refObjectName || finding.REFOBJECTNAME,
        rating_code:
          finding.rating ||
          finding.RATING ||
          finding.ratingCode ||
          finding.RATINGCODE
      } as ScoringRecord;
    })
    .filter((finding) => {
      if (!finding.objectType || !finding.objectName) {
        LOG.warn('Invalid finding', { finding });
        return false;
      }
      return true;
    });

  if (scoringRecordList == null || scoringRecordList.length == 0) {
    LOG.info('No Records to import');
    return;
  }

  await INSERT.into(entities.ScoringRecords).entries(scoringRecordList);
  if (tx) {
    await tx.commit();
  }

  LOG.info(`Importing Scoring Findings ${scoringRecordList.length}`);
  let upsertCount = 0;

  // Reset Latest Scoring Run Import for all Development Objects of this System, so we exclude objects, that don't have any Findings anymore
  await UPDATE(entities.DevelopmentObjects)
    .set({ latestScoringImportId: '' })
    .where({ systemId: scoringImport.systemId });

  const developmentObjectMap = await getDevelopmentObjectMap();
  let progressCount = 0;
  const chunkSize = 1000;
  for (let i = 0; i < scoringRecordList.length; i += chunkSize) {
    LOG.info(
      `Processing ${i}/${scoringRecordList.length}`
    );
    const chunk = scoringRecordList.slice(i, i + chunkSize);

    const developmentObjectUpsert = [] as Partial<DevelopmentObject>[];
    for (const scoringRecord of chunk) {
      progressCount++;
      // Try to find a Development Object
      const key = getDevelopmentObjectIdentifier(scoringRecord);
      const developmentObjectDB = developmentObjectMap.get(key);
      if (!developmentObjectDB) {
        // Create a new Development Object
        const developmentObject = {
          objectType: scoringRecord.objectType || '',
          objectName: scoringRecord.objectName,
          systemId: scoringRecord.systemId || '',
          devClass: scoringRecord.devClass || '',
          latestScoringImportId: scoringImport.ID,
          languageVersion_code: 'X', // Default
          namespace: ''
        } as DevelopmentObject;

        developmentObject.score = await calculateScore(developmentObject);
        developmentObject.namespace = determineNamespace(developmentObject);
      
    

        if (
          !developmentObject.devClass ||
          !developmentObject.objectName ||
          !developmentObject.objectType ||
          !developmentObject.systemId
        ) {
          LOG.error('Invalid Development Object', { developmentObject });
        }
        developmentObjectUpsert.push(developmentObject);
        const diffKey = getDevelopmentObjectIdentifier(developmentObject);
        if (diffKey !== key) {
          LOG.error('Key mismatch', { key: key, diffKey: diffKey });
        }
        developmentObjectMap.set(key, developmentObject);
        upsertCount++;
      } else {
        if (developmentObjectDB.latestScoringImportId !== scoringImport.ID) {
          developmentObjectDB.latestScoringImportId = scoringImport.ID;

          // Update the score
          if (
            !developmentObjectDB.devClass ||
            !developmentObjectDB.objectName ||
            !developmentObjectDB.objectType ||
            !developmentObjectDB.systemId
          ) {
            LOG.error('Invalid Development Object', { developmentObjectDB });
          }
          developmentObjectDB.score = await calculateScore(developmentObjectDB);
          developmentObjectDB.namespace =
            determineNamespace(developmentObjectDB);
       
          developmentObjectUpsert.push(developmentObjectDB);
          upsertCount++;
        } else {
          LOG.debug('Development Object already scored', {
            developmentObjectDB
          });
        }
      }
    }
    if (developmentObjectUpsert.length > 0) {
      await UPSERT.into(entities.DevelopmentObjects).entries(
        developmentObjectUpsert
      );
      if (tx) {
        await tx.commit();
      }
    }
    if (updateProgress)
      await updateProgress(
        Math.round((100 / scoringRecordList.length) * progressCount)
      );
  }
  if (upsertCount > 0) {
    LOG.info(`Upserted ${upsertCount} new DevelopmentObject(s)`);
  }
};

export const importScoringById = async (
  scoringImportId,
  tx: Transaction,
  updateProgress?: (progress: number) => Promise<void>
) => {
  const scoringRunImport = await SELECT.one
    .from(entities.Imports, (d) => {
      d.ID, d.status, d.title, d.file, d.systemId;
    })
    .where({ ID: scoringImportId });
  await importScoring(scoringRunImport, tx, updateProgress);
};