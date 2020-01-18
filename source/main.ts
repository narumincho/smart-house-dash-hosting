import { Elm } from "./Main.elm";
import * as firebase from "firebase/app";
import "firebase/firestore";

const node = document.createElement("div");
document.body.appendChild(node);

firebase.initializeApp({
  apiKey: "AIzaSyAydnMzzzonl0Y6qxhKTOmfB4s5isLvNHM",
  authDomain: "smart-house-dash.firebaseapp.com",
  projectId: "smart-house-dash",
  storageBucket: "smart-house-dash.appspot.com"
});
firebase.firestore();
firebase
  .firestore()
  .collection("data")
  .get()
  .then(data => {
    Elm.Main.init({
      flags: data.docs.map(doc => [
        new Date(doc.id).getTime(),
        Object.entries(doc.data())
      ]),
      node
    });
  });
