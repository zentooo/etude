self.addEventListener("message", function(evt) {
    var audio = new Audio(evt.data);
    audio.play();
    self.postMessage(evt.data);
});
