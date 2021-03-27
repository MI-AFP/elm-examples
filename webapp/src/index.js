'use strict';

import { Elm } from './elm/Main.elm';

const LOCAL_STORAGE_TOKEN_KEY = 'token';

const app = Elm.Main.init({
  flags: localStorage.getItem(LOCAL_STORAGE_TOKEN_KEY),
});

app.ports.saveToken.subscribe((token) => {
  localStorage.setItem(LOCAL_STORAGE_TOKEN_KEY, token);
});
