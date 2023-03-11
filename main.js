import "./style.css";
import { Elm } from "./src/Main.elm";

if (!document.startViewTransition) {
  alert(
    "Your browser doesn't support the View Transitions API! Only Chrome supports View Transitions right now."
  );
}

const app = Elm.Main.init({
  flags: location.href,
  node: document.querySelector("#app div"),
});

// Inform app of browser navigation (the BACK and FORWARD buttons)
window.addEventListener("popstate", function (event) {
  startTransition(location.href);
});

// Change the URL upon request, inform app of the change.
app.ports.pushUrl.subscribe(function (path) {
  startTransition(new URL(`${location.protocol}${location.host}${path}`).href);
});

function startTransition(url) {
  if (document.startViewTransition) {
    app.ports.onTransitionStart.send(url);
    document.startViewTransition(() => {
      history.pushState({}, "", url);
      app.ports.onUrlChange.send(location.href);
    });
  } else {
    app.ports.onTransitionStart.send(url);
    history.pushState({}, "", url);
    app.ports.onUrlChange.send(location.href);
  }
}
