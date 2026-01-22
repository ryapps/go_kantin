const admin = require("firebase-admin");
const fs = require("fs");

admin.initializeApp({
  credential: admin.credential.cert(require("./serviceAccountKey.json")),
});

const db = admin.firestore();
const data = JSON.parse(fs.readFileSync("./data.json", "utf8"));

async function uploadCollection(collectionName, collectionData) {
  const batch = db.batch();

  for (const docId in collectionData) {
    const docRef = db.collection(collectionName).doc(docId);
    batch.set(docRef, collectionData[docId]);
  }

  await batch.commit();
  console.log(`Uploaded ${collectionName}`);
}

async function main() {
  for (const collectionName in data) {
    await uploadCollection(collectionName, data[collectionName]);
  }
  console.log("All data uploaded");
}

main();
