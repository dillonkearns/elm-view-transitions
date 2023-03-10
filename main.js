import "./style.css";
import { Elm } from "./src/Main.elm";

const app = Elm.Main.init({
    flags: location.href,
    node: document.querySelector("#app div")
});

// Inform app of browser navigation (the BACK and FORWARD buttons)
window.addEventListener('popstate', function (event) {
    console.log('onUrlChange!');
    app.ports.onUrlChange.send(location.href);

});

// Change the URL upon request, inform app of the change.
app.ports.pushUrl.subscribe(function(url) {
    console.log('onUrlChange!', url);
    history.pushState({}, '', url);
    app.ports.onUrlChange.send(location.href);
});
