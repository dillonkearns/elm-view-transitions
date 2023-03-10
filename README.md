# View Transitions API in Elm

https://user-images.githubusercontent.com/1384166/224448950-5c90bf7f-9376-4a76-abd1-fa27554ac234.mp4

## Background

[View Transitions API docs](https://developer.chrome.com/docs/web-platform/view-transitions/)

This example is the most relevant demo:

- https://simple-set-demos.glitch.me/6-expanding-image/
- https://glitch.com/edit/#!/simple-set-demos?path=6-expanding-image%2Fscript.js%3A1%3A0

This repo uses the single-page app wiring described in <https://github.com/elm/browser/blob/1.0.2/notes/navigation-in-elements.md>.

## Architecture

### Transition state

I defined a `Transition` type:

```elm
type Transition
   = To Route
   | From Route
```

Essentially what is happening here is we are capturing a "snapshot" of a "Transition To state" and a "Transition From state".

That is, once we know which Route we are transitioning to, we can set that transition. This lets the user set any related CSS to tell the View Transitions API which elements are which on each page relative to that specific to/from transition.

For example, in this app I have `type Route = Index | Detail String`.

Let's say we being on `Index`. Our initial `Model` is:

```elm
{ route = Index
, transition = Just (To Index)
}
```

Once a link to a detail page is clicked, `pushUrl` is called and we call the JS `app.ports.onTransitionStart.send(url);` [which triggers the TransitionStart Msg](https://github.com/dillonkearns/elm-view-transitions/blob/fa29bb6ba81ff4a454f271daba72e3c0824a8244/src/Main.elm#L14-L19).

That gives us a `Model`:

```elm
{ route = Index
, transition = Just (To (Detail "1"))
}
```

Just for enough time for the `view` to render with a `class "title-element"`, which has `view-transition-name: title-element;` on the first item on the Index page. This is the first snapshot ("Transition To state").

Finally, we call the magic function, `document.startViewTransition`. Within the callback function to `startViewTransition`, we
do

```js
history.pushState({}, "", url);
app.ports.onUrlChange.send(location.href);
```

This changes the browser's URL, and `onUrlChange` triggers the Msg `UrlChanged`.

Now our Model becomes:

```elm
{ route = Detail "1"
, transition = Just (From Index)
}
```

This is our "Transition From State".

In this particular example, we don't need the context that we transitioned from `Index` since we can always safely add the `class "title-element"` to give the `view-transition-name: title-element` to the heading element. But in the case where we do the reverse transition (from (Detail "1"), to Index), we need to use the "Transition From State".

## Integrations

This could be integrated into Elm in a more core way, or more likely into related Elm meta-frameworks like `elm-spa`, `elm-land`, `elm-pages`. I'm planning to integrate this into a new release of `elm-pages`.

## Resources

- [Related `elm/browser` issue #131](https://github.com/elm/browser/issues/131)
- [Discussion thread for supporting transition animations in `elm-pages`](https://github.com/dillonkearns/elm-pages/issues/225)

## Running this repo

Proof of concept for the Chrome View Transitions API in Elm.

To run locally, clone and run:

```shell
npm install
npm start
```
