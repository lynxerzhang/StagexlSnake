import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math';
import 'dart:async';

void main() {
  init();
}

Stage stage;
RenderLoop renderLoop;

const String LEFT = "left";
const String RIGHT = "right";
const String TOP = "top";
const String BOTTOM = "bottom";

String currentDirect = LEFT;

Sprite rootS;
Sprite player;
Sprite food;
int size;
int column;
int rows;
List<List> foodAry;
List<List> pathAry;
List currentFoodAry;
Timer timer;

void initStage(){
  var canvas = html.query("#stage");
  stage = new Stage("renderStage", canvas);
  renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  
  stage.focus = stage;
  stage.align = StageAlign.TOP_LEFT;
  stage.scaleMode = StageScaleMode.NO_SCALE;
}


void init(){
  initStage();
  initSnake();
  initSnakeBody();
  setMotion();
}

void setMotion(){
  var ms = new Duration(milliseconds:60);
  timer = new Timer.periodic(ms, onTimerHandler);
  stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
}

void keyDownHandler(KeyboardEvent event){
  if(event.keyCode == 37 && currentDirect != RIGHT){
    setDirection(LEFT);
  }
  else if(event.keyCode == 38 && currentDirect != BOTTOM){
    setDirection(TOP);
  }
  else if(event.keyCode == 39 && currentDirect != LEFT){
    setDirection(RIGHT); 
  }
  else if(event.keyCode == 40 && currentDirect != TOP){
    setDirection(BOTTOM);
  }
}


void onTimerHandler(Timer t){
  reDraw();
}

void reDraw(){
  path();
  player.graphics.clear();
  int len = pathAry.length;
  while(--len > -1){
      player.graphics.rect(size * pathAry[len][0], size * pathAry[len][1], size, size);
  }
  player.graphics.strokeColor(Color.Black, 1);
  player.graphics.fillColor(Color.Blue);
  if(checkEatSelf()){
    initSnakeBody();
  }
  else{
    checkEatFood();
  }
}

void checkEatFood(){
  if(pathAry[0][0] == currentFoodAry[0] && pathAry[0][1] == currentFoodAry[1]){
    createSnakeBody();
    createSnakeFood();
  }
}

void createSnakeBody(){
  pathAry.add(pathAry[pathAry.length - 1].toList());
}


bool checkEatSelf(){
  int len = pathAry.length;
  List head = pathAry[0];
  for(var i = 1; i < len; i ++){
    if(head[0] == pathAry[i][0] && head[1] == pathAry[i][1]){
      return true;
    }
  }
  return false;
}

void path(){
  pathAry.insert(0, pathAry[0].toList());
  pathAry.removeAt(pathAry.length - 1);
  if(currentDirect == LEFT){
    pathAry[0][0] - 1 < 0 ? pathAry[0][0] = column - 1 : pathAry[0][0]--;
  }
  else if(currentDirect == RIGHT){
    pathAry[0][0] + 1 > column - 1 ? pathAry[0][0] = 0 : pathAry[0][0]++;
  }
  else if(currentDirect == TOP){
    pathAry[0][1] - 1 < 0 ? pathAry[0][1] = rows - 1 : pathAry[0][1]--;
  }
  else if(currentDirect == BOTTOM){
    pathAry[0][1] + 1 > rows - 1 ? pathAry[0][1] = 0 : pathAry[0][1]++;
  }
}


void initSnake(){
  rootS = CreationFactory.createSprite("root", stage);
  player = CreationFactory.createSprite("player");
  food = CreationFactory.createSprite("food");
  
  rootS.addChild(player);
  rootS.addChild(food);
  
  size = 10;
  
  column = (stage.stageWidth / size).floor() - 10;//70
  rows = (stage.stageHeight / size).floor() - 10;//50
  
  rootS.graphics.rect(0, 0, column * size, rows * size);
  rootS.graphics.fillColor(0xFF333333);
  
  rootS.x = (stage.stageWidth - rootS.width) * .5;
  rootS.y = (stage.stageHeight - rootS.height) * .5;
  
  foodAry = new List<List>();
  for(var k = 0; k < rows * column; k ++){
    foodAry.add([(k % column).floor(), (k / column).floor()]);
  }
  
  pathAry = new List<List>();
}

void initSnakeBody(){
  if(pathAry.length > 0){
     pathAry.clear();
  }
  pathAry.add([(column * .5).floor(), (rows * .5).floor()]);
  player.graphics.clear();
  setDirection(LEFT);
  createSnakeFood();
}

void createSnakeFood(){
  food.graphics.clear();
  List k = foodAry.where(check).toList();
  var n = new Random();
  currentFoodAry = k[(n.nextDouble() * k.length).floor()];
  food.graphics.rect(currentFoodAry[0] * size, currentFoodAry[1] * size, size, size);
  food.graphics.fillColor(Color.Yellow);
}

bool check(List t){
  int len = pathAry.length;
  for(var j = 0; j < len; j ++){
      if(pathAry[j][0] == t[0] && pathAry[j][1] == t[1]){
          return false;
      }
  }
  return true;
}

void setDirection(String val){
  currentDirect = val;
}

class CreationFactory{
    static Sprite createSprite([String name, DisplayObjectContainer parent]){
        Sprite s = new Sprite();
        s.mouseChildren = s.mouseEnabled = false;
        if(name != null){
          s.name = name;
        }
        if(parent != null){
          parent.addChild(s);
        }
        return s;
    }
}



