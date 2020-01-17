import { Elm } from "./Main.elm";
import * as firebase from "firebase/app";
import "firebase/firestore";
(async () => {
  const node = document.createElement("div");
  document.body.appendChild(node);

  const key = await fetch(
    "https://smart-house-dash.web.app/__/firebase/init.json"
  );
  const keyAsJson = await key.json();
  firebase.initializeApp(keyAsJson);
  firebase.firestore();

  const app = Elm.Main.init({
    flags: {},
    node
  });
})();
