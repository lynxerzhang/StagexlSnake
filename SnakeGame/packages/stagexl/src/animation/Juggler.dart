part of stagexl;

class Juggler implements Animatable {

  final List<Animatable> _animatables = new List<Animatable>();
  int _animatablesCount = 0;
  num _elapsedTime = 0.0;

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  num get elapsedTime => _elapsedTime;

  //-----------------------------------------------------------------------------------------------

  void add(Animatable animatable) {

    if (animatable == null)
      return;

    if (this.contains(animatable))
      return;

    if (_animatablesCount == _animatables.length) {
      _animatables.add(animatable);
    } else {
      _animatables[_animatablesCount] = animatable;
    }

    _animatablesCount++;
  }

  //-----------------------------------------------------------------------------------------------

  void remove(Animatable animatable) {

    if (animatable == null)
      return;

    for(int i = 0; i < _animatablesCount; i++) {
      if (identical(_animatables[i], animatable)) {
        _animatables[i] = null;
        break;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  bool contains(Animatable animatable) {

    if (animatable == null)
      return false;

    for(int i = 0; i < _animatablesCount; i++) {
      if (identical(_animatables[i], animatable)) {
        return true;
      }
    }

    return false;
  }

  //-----------------------------------------------------------------------------------------------

  void removeTweens(DisplayObject displayObject) {

    if (displayObject == null)
      return;

    for(int i = 0; i < _animatablesCount; i++) {
      var animatable = _animatables[i];
      if (animatable != null && animatable is Tween){
        if (identical(animatable.displayObject, displayObject)) {
          _animatables[i] = null;
        }
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  bool containsTweens(DisplayObject displayObject) {

    if (displayObject == null)
      return false;

    for(int i = 0; i < _animatablesCount; i++) {
      var animatable = _animatables[i];
      if (animatable != null && animatable is Tween) {
        if (identical(animatable.displayObject, displayObject)) {
          return true;
        }
      }
    }

    return false;
  }

  //-----------------------------------------------------------------------------------------------

  void purge() {

    for(int i = 0; i < _animatablesCount; i++) {
      _animatables[i] = null;
    }

    _animatablesCount = 0;
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  Tween tween(DisplayObject displayObject, num time, [EaseFunction transitionFunction]) {

    Tween tween = transitionFunction != null ? new Tween(displayObject, time, transitionFunction) : new Tween(displayObject, time);
    add(tween);

    return tween;
  }

  //-----------------------------------------------------------------------------------------------

  Transition transition(num startValue, num targetValue, num time, EaseFunction transitionFunction, void onUpdate(num value)) {

    Transition transition = new Transition(startValue, targetValue, time, transitionFunction);
    transition.onUpdate = onUpdate;
    add(transition);

    return transition;
  }

  //-----------------------------------------------------------------------------------------------

  DelayedCall delayCall(Function action, num delay) {

    DelayedCall delayedCall = new DelayedCall(action, delay);
    add(delayedCall);

    return delayedCall;
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  bool advanceTime(num time) {

    _elapsedTime += time;

    // Call advanceTime of current animatables.
    // Do not call advanceTime of newly added animatables.
    // Adjust _animatables List.

    int animatablesCount = _animatablesCount;
    int tail = 0;

    for(int head = 0; head < animatablesCount; head++) {

      var animatable = _animatables[head];
      if (animatable == null) continue;

      if (animatable.advanceTime(time) == false) {
        _animatables[head] = null;
        continue;
      }

      if (tail != head) {
        _animatables[tail] = _animatables[head];
        _animatables[head] = null;
      }

      tail++;
    }

    if (tail != animatablesCount) {

      for(int head = animatablesCount; head < _animatablesCount; head++) {
        _animatables[tail++] = _animatables[head];
        _animatables[head] = null;
      }

      _animatablesCount = tail;
    }

    return true;
  }

}
