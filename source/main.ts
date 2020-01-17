import { Elm } from "./Main.elm";
import * as firebase from "firebase/app";
import "firebase/firestore";

const node = document.createElement("div");
document.body.appendChild(node);

firebase.initializeApp({
  apiKey: "AIzaSyAydnMzzzonl0Y6qxhKTOmfB4s5isLvNHM",
  authDomain: "smart-house-dash.firebaseapp.com",
  databaseURL: "https://smart-house-dash.firebaseio.com",
  messagingSenderId: "154129645115",
  projectId: "smart-house-dash",
  storageBucket: "smart-house-dash.appspot.com"
});
firebase.firestore();
firebase
  .firestore()
  .collection("data")
  .get()
  .then(data => {
    const dataMap: Map<string, Array<[number, number]>> = new Map();
    for (const d of data.docs) {
      const document = d.data();
      for (const [key, value] of Object.entries(document)) {
        const keyData = dataMap.get(key);
        if (keyData === undefined) {
          dataMap.set(key, [[new Date(d.id).getTime(), value]]);
          continue;
        }
        keyData.push([new Date(d.id).getTime(), value]);
      }
    }

    const app = Elm.Main.init({
      flags: [...dataMap],
      node
    });
  });
