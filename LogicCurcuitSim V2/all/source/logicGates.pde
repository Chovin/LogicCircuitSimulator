import processing.awt.PSurfaceAWT.SmoothCanvas;
import javax.swing.JFrame;
import java.awt.Dimension;


ArrayList<Gate> gates = new ArrayList<Gate>();
ArrayList<CustomGate> customGates = new ArrayList<CustomGate>();
ArrayList<Button> buttons = new ArrayList<Button>();
Gate editing;
int outputIndex = -1;
PImage[] images = new PImage[7];
float globalScale = 1;
PVector globalOffset;
String globalLines = "l turn line";
Boolean shouldDraw = true, creatingName = false;
CustomGate copy = null;

Boolean creatingCustom = false;
PVector[] customPoints = new PVector[3];


int[] updates = new int[4]; //draw, powercheck, polycheck, all

void setup() {
  size(1400, 800);
  surface.setResizable(true);
  registerMethod("pre", this);
 
  final SmoothCanvas sc = (SmoothCanvas) getSurface().getNative();
  final JFrame jf = (JFrame) sc.getFrame();
  final Dimension d = new Dimension(400, 300);
  jf.setMinimumSize(d);
  
  buttons.add(new Button("AND", new PVector(15, buttons.size()*85+15)));
  buttons.add(new Button("NAND", new PVector(15, buttons.size()*85+15)));
  buttons.add(new Button("NOT", new PVector(15, buttons.size()*85+15)));
  buttons.add(new Button("OR", new PVector(15, buttons.size()*85+15)));
  buttons.add(new Button("NOR", new PVector(15, buttons.size()*85+15)));
  buttons.add(new Button("XOR", new PVector(15, buttons.size()*85+15)));
  buttons.add(new Button("XNOR", new PVector(15, buttons.size()*85+15)));
  buttons.add(new Button("INPUT", new PVector(15, buttons.size()*85+15)));
  buttons.add(new Button("OUTPUT", new PVector(15, buttons.size()*85+15)));

  images[0] = loadImage("Data/recycle-bin.png");
  images[1] = loadImage("Data/blueprint.png");
  images[2] = loadImage("Data/delete-blueprint.png");
  images[3] = loadImage("Data/lines.png");
  images[4] = loadImage("Data/resize.png");
  images[5] = loadImage("Data/copy.png");
  images[6] = loadImage("Data/paste.png");
  globalOffset = new PVector(0, 0);
  frameRate(60);
}

void pre() {
  shouldDraw = true;
  surface.setSize(constrain(width, 400, 10000), constrain(height, 300, 10000));
}

boolean pixelInPoly(PVector[] verts, PVector pos) {
  int i, j;
  boolean c=false;
  int sides = verts.length;
  pos = PVector.div(pos, globalScale);
  for (PVector p : verts) {
    p = PVector.mult(p, globalScale);
  }
  for (i=0, j=sides-1; i<sides; j=i++) {
    if (( ((verts[i].y <= pos.y) && (pos.y < verts[j].y)) || ((verts[j].y <= pos.y) && (pos.y < verts[i].y))) &&
      (pos.x < (verts[j].x - verts[i].x) * (pos.y - verts[i].y) / (verts[j].y - verts[i].y) + verts[i].x)) {
      c = !c;
    }
  }
  updates[2] += 1;
  updates[3] += 1;
  return c;
}

void line(PVector point1, PVector point2, String type, Boolean os) {
  if (os) {
    strokeWeight(1);
    stroke(255);
  }
  switch(type) { 
  case "stright": 
    line(point1.x, point1.y, point2.x, point2.y);
    break;
  case "stright spline":
    line(point1.x, point1.y, point1.x + (point2.x-point1.x)/3, point1.y);
    line(point1.x + (point2.x-point1.x)/3, point1.y, point2.x - (point2.x-point1.x)/3, point2.y);
    line(point2.x - (point2.x-point1.x)/3, point2.y, point2.x, point2.y);
    break;
  case "spline":
    float medianX = ((point1.x + (point2.x-point1.x)/3)+(point2.x - (point2.x-point1.x)/3))/2;
    float medianY = (point1.y+point2.y)/2;
    noFill();
    bezier(point1.x, point1.y, (point1.x+(point2.x-point1.x)/3), point1.y, ((point1.x+(point2.x-point1.x)/3)+medianX)/2, (point1.y+medianY)/2, medianX, medianY);
    bezier(medianX, medianY, ((point2.x-(point2.x-point1.x)/3)+medianX)/2, (point2.y+medianY)/2, point2.x-(point2.x-point1.x)/3, point2.y, point2.x, point2.y);
    break;
  case "l turn line":
    line(point1.x,point1.y,(point1.x+point2.x)/2,point1.y);
    line((point1.x+point2.x)/2,point1.y,(point1.x+point2.x)/2,point2.y);
    line((point1.x+point2.x)/2,point2.y,point2.x,point2.y);
    break;
  }
  shouldDraw = true;
  updates[0] += 1;
  updates[3] += 1;
}


void draw() {
  if(frameCount % 100 == 0) {
   //println("\nAll Updates Last 100 Frames:\n\tAll: " + updates[3] + "\t" + nf(updates[3]/100.0f,0,2) + " ~ updates per frame." + "\n\tDrawing:" + updates[0] + "\n\tPoly Check:" + updates[1] + "\n\tGate Powered:" + updates[2]);
   updates = new int[4];
  }
  if(shouldDraw){
    background(51);
    drawBackground();
    
    for (CustomGate cg : customGates) {
      cg.show();
    }
    
    for (Gate s : gates) {
      s.show();
      //s.calculatePowered();
    }

    stroke(255);
    noFill();

    if (editing != null && outputIndex >= 0) line(PVector.mult(PVector.add(editing.position, editing.outputs.get(outputIndex)), globalScale), new PVector(mouseX, mouseY), globalLines, true);

    noStroke();
    fill(200);
    rect(0, 0, 80, height);
    fill(255);
    rect(80,0,width-80,50);
    if (outputIndex == -2) {
      fill(200, 30, 60, map(mouseY,height-300,height-100,0,70));
      rect(80, height-60, width-80, 60);
      if (mouseY >= height - 100){
        image(images[0], width/2, height-60, 60, 60);
      }
    }
    
    //Draw top buttons
    pushMatrix();
    //Creating Custom
    if(!creatingCustom){
      fill(200); 
    } else {
      fill(20,230,200);
    }
    rect(90,5,40,40);
    image(images[1],93,8);
    
    //Remove Custom
    if(outputIndex != -3){
      fill(200); 
    } else {
      fill(20,230,200);
    }
    rect(140,5,40,40);
    image(images[2],143,8);
    
    //Change Lines
    fill(230,200,20);
    rect(190,5,40,40);
    image(images[3],193,8);
    
    //Hide Custom
    if(outputIndex != -4){
      fill(200); 
    } else {
      fill(20,230,200);
    }
    rect(240,5,40,40);
    image(images[4],243,8);
    
    //Copy
    if(outputIndex != -5){
      fill(200); 
    } else {
      fill(20,230,200);
    }
    rect(290,5,40,40);
    image(images[5],293,8);
    
    //Paste
    if(outputIndex != -6){
      fill(200); 
    } else {
      fill(20,230,200);
    }
    rect(340,5,40,40);
    image(images[6],343,8);
    popMatrix();
    
    
    pushMatrix();
    stroke(255);
    strokeWeight(1);
    noFill();
    if(creatingCustom && customPoints[0] != null){
      rect(customPoints[0].x,customPoints[0].y,mouseX-customPoints[0].x,mouseY-customPoints[0].y);
    } else if (customPoints[1] != null) {
      rect(customPoints[0].x,customPoints[0].y,customPoints[1].x - customPoints[0].x,customPoints[1].y - customPoints[0].y);
    }
    popMatrix();

    for (Button b : buttons) {
      b.show();
    }
  
    textSize(16);
    textAlign(RIGHT);
    text("Zoom: x"+nf(globalScale,0,1),width-10,16);
    text("Gates: " + (gates.size()+customGates.size()),width-10,32);
    text("FPS: " + round(frameRate),width-10,48);
    shouldDraw = false;
    updates[0] += 1;
    updates[3] += 1;
  }
}

void mousePressed() {
  if (creatingName) return;
  if(creatingCustom){
    customPoints[0] = new PVector(mouseX,mouseY);
  } else {
    if (mouseX > 80) {
      for (Gate s : gates) {
        if((s.hidden == false || s.type == "OUTPUTbp") && s.position.x > -100 && s.position.x < (width+20)/globalScale && s.position.y > -100 && s.position.y < (height+20)/globalScale && outputIndex > -3){
          for (int i = 0; i < s.outputs.size(); i++) {
            if (PVector.dist(new PVector(mouseX, mouseY), PVector.mult(PVector.add(s.position, s.outputs.get(i)), globalScale)) < (8*globalScale)) {
              editing = s;
              outputIndex = i;
              break;
            }
          }
          if (s.hidden == false && pixelInPoly(s.shapes.get(0).points, PVector.sub(new PVector(mouseX, mouseY), PVector.mult(s.position, globalScale))) && outputIndex > -3) {
            editing = s;
            outputIndex = -2;
          }
          if (outputIndex != -1) break;
        }
      }
      
      if(editing == null){
        for (CustomGate s : customGates) {
          if(s.position.x > -100 && s.position.x < (width+20)/globalScale && s.position.y > -100 && s.position.y < (height+20)/globalScale){
            if (pixelInPoly(s.shapes.get(0).points, PVector.sub(new PVector(mouseX, mouseY), PVector.mult(s.position, globalScale)))) {
              editing = s;
              if(outputIndex > -2) {
                outputIndex = -2;
              }
            }
            //if (outputIndex != -1) break;
          }
        }
      }
    } else {
      float holder = globalScale;
      globalScale = 1;
      for ( Button b : buttons) {
        if (pixelInPoly(b.shapes.get(0).points, PVector.sub(new PVector(mouseX, mouseY), b.position))) {
          Gate _new = null;
          globalScale = holder;
          switch(b.name) {
          case "AND": 
            _new = new Gate("AND", PVector.div(new PVector(mouseX, mouseY),globalScale));
            gates.add(_new);
            break;
          case "NAND": 
            _new = new Gate("NAND", PVector.div(new PVector(mouseX, mouseY),globalScale));
            gates.add(_new);
            break;
          case "NOT": 
            _new = new Gate("NOT", PVector.div(new PVector(mouseX, mouseY),globalScale));
            gates.add(_new);
            break;
          case "OR": 
            _new = new Gate("OR", PVector.div(new PVector(mouseX, mouseY),globalScale));
            gates.add(_new);
            break;
          case "NOR": 
            _new = new Gate("NOR", PVector.div(new PVector(mouseX, mouseY),globalScale));
            gates.add(_new);
            break;
          case "XOR": 
            _new = new Gate("XOR", PVector.div(new PVector(mouseX, mouseY),globalScale));
            gates.add(_new);
            break;
          case "XNOR": 
            _new = new Gate("XNOR", PVector.div(new PVector(mouseX, mouseY),globalScale));
            gates.add(_new);
            break;
          case "INPUT": 
            _new = new Gate("INPUT", PVector.div(new PVector(mouseX, mouseY),globalScale));
            gates.add(_new);
            break;
          case "OUTPUT": 
            _new = new Gate("OUTPUT", PVector.div(new PVector(mouseX, mouseY),globalScale));
            gates.add(_new);
            break;
          }
          editing = _new;
          outputIndex = -2;
        }
      }
    }
  }
  shouldDraw = true;
}

void keyPressed(){
  if(creatingName){
    if(keyCode > 31 && keyCode < 127 && customGates.get(customGates.size()-1).name.length() < 20){
      if(customGates.get(customGates.size()-1).name == "enter name"){
        customGates.get(customGates.size()-1).name = "" + key;
      } else {
        customGates.get(customGates.size()-1).name += key;
      }
    } else if (keyCode == BACKSPACE && customGates.get(customGates.size()-1).name.length() > 0){
      customGates.get(customGates.size()-1).name = customGates.get(customGates.size()-1).name.substring(0,customGates.get(customGates.size()-1).name.length()-1);
    } else if (keyCode == ENTER){
      creatingName = false;
    }
  } else {
    if(key == '1'){
      creatingCustom = true;
    } else if (key == '2') {
      outputIndex = -3;
    }  else if (key == '3') {
      if(globalLines == "l turn line") globalLines = "stright";
      else if(globalLines == "stright") globalLines = "stright spline";
      else if(globalLines == "stright spline") globalLines = "spline";
      else if(globalLines == "spline") globalLines = "l turn line";
    }  else if (key == '4') {
      outputIndex = -4;
    } else if (key == 3 && keyCode == 67) {
      outputIndex = -5;
    } else if (key == 22 && keyCode == 86) {
      outputIndex = -6;
    }
  }
  println((int)key, keyCode);
  shouldDraw = true;
}

void mouseReleased() {
  if (creatingName) return;
  if(outputIndex == -3){
    for(int i = customGates.size() -1; i >= 0; i--){
      if (customGates.get(i) == editing) {
        if (customGates.get(i).minimized) customGates.get(i).minimize();
        customGates.get(i).delete(false);
      }
    }
  }
  
  if(outputIndex == -4){
    for(int i = customGates.size() -1; i >= 0; i--){
      if (customGates.get(i) == editing) {
        customGates.get(i).minimize();
      }
    }
  }
  
  if(outputIndex == -5){
    for(int i = customGates.size() -1; i >= 0; i--){
      if (customGates.get(i) == editing) {
        copy = customGates.get(i);
        println(copy);
      }
    }
  }
  
  if(outputIndex == -6){
    CustomGate cg = new CustomGate(new Shape(new PVector[]{new PVector(0,0,0),new PVector(0,0),new PVector(0,0), new PVector(0,0)},color(0,90,120,100),false),PVector.div(new PVector(0,0),globalScale),PVector.sub(new PVector(0,0),new PVector(0,0)));
    println(copy.localGates.size());
    customGates.add(cg);
    customGates.get(customGates.size()-1).position = new PVector(mouseX/globalScale,mouseY/globalScale);
    customGates.get(customGates.size()-1).name = copy.name;
    customGates.get(customGates.size()-1).shapes = copy.shapes;
    customGates.get(customGates.size()-1).locked = copy.locked;
    customGates.get(customGates.size()-1).blueprintSize = copy.blueprintSize;
    customGates.get(customGates.size()-1).minimized = copy.minimized;
    customGates.get(customGates.size()-1).holderShapes = copy.holderShapes;
    for(Gate g : copy.localGates){ //<>//
      Gate newGate = new Gate("AND", PVector.div(new PVector(mouseX, mouseY),globalScale));
      newGate.shapes = g.shapes;
      newGate.outline = g.outline;
      newGate.type = g.type;
      newGate.position = PVector.add(new PVector(mouseX/globalScale,mouseY/globalScale),PVector.sub(g.position,copy.position));
      newGate.inputs = g.inputs;
      newGate.outputs = g.outputs;
      newGate.connections_in = new Connection[newGate.inputs.size()]; // g.connections_in;
      newGate.connections_out = new ArrayList<Gate>();// g.connections_out;
      newGate.powered = g.powered;
      newGate.hidden = g.hidden;
      newGate.powerChecks = g.powerChecks;
      customGates.get(customGates.size()-1).localGates.add(newGate);
      gates.add(newGate);
    }
    for(int i = 0; i < copy.localGates.size(); i++){
      for(int j = 0; j < copy.localGates.get(i).connections_in.length; j++){
       if(copy.localGates.get(i).connections_in[j] == null) cg.localGates.get(i).connections_in[j] = null;
       else cg.localGates.get(i).connections_in[j] = new Connection(cg.localGates.get(copy.localGates.indexOf(copy.localGates.get(i).connections_in[j].connector)),copy.localGates.get(i).connections_in[j].inputIndex);
      }
      
      for(int j = 0; j < copy.localGates.get(i).connections_out.size(); j++){
        cg.localGates.get(i).connections_out.add(cg.localGates.get(copy.localGates.indexOf(copy.localGates.get(i).connections_out.get(j))));
      }
    }
    println("Index: " + copy.localGates.indexOf(gates.get(3)));
  }
  
  if(creatingCustom) {
    customPoints[1] = new PVector(mouseX,mouseY);
    creatingCustom = false;
    CustomGate cg = new CustomGate(new Shape(new PVector[]{new PVector(0,0,0),new PVector((customPoints[1].x-customPoints[0].x)/globalScale,0),new PVector((customPoints[1].x-customPoints[0].x)/globalScale,(customPoints[1].y-customPoints[0].y)/globalScale), new PVector(0,(customPoints[1].y-customPoints[0].y)/globalScale)},color(0,90,120,100),false),PVector.div(customPoints[0],globalScale),PVector.sub(customPoints[1],customPoints[0]));
    println(customPoints[0].x/globalScale,customPoints[0].y/globalScale);
    println(customPoints[1].x/globalScale,customPoints[1].y/globalScale);
    for(Gate g : gates){
      if((g.hidden == false || g.type == "INPUTbp" || g.type == "OUTPUTbp") && g.position.x >= min(customPoints[0].x,customPoints[1].x)/globalScale && g.position.x <= max(customPoints[0].x,customPoints[1].x)/globalScale && g.position.y >= min(customPoints[0].y,customPoints[1].y)/globalScale && g.position.y <= max(customPoints[0].y,customPoints[1].y)/globalScale){
        cg.localGates.add(g);
        println(g.position,g.type);
      } else {
        println(g.position);
      }
    }
    Boolean inputFound = false, outputFound = false;
    for(Gate g : cg.localGates){
      if (g.type == "INPUT") inputFound = true;
      if (g.type == "OUTPUT") outputFound = true;
    }
    if(inputFound && outputFound) {
      cg.setupGate();
      customGates.add(cg);
      creatingName = true;
    } else {
      println("failed to create custom gate");
    }
    customPoints = new PVector[2];
  } else {
    if (outputIndex != -2)
      for (Gate s : gates) {
        if((s.hidden == false || s.type == "INPUTbp" || s.type == "OUTPUTbp") && s.position.x > -100 && s.position.x < (width+20)/globalScale && s.position.y > -100 && s.position.y < (height+20)/globalScale){
          if(s != editing){
            for (int i = 0; i < s.inputs.size(); i++) {
              if (PVector.dist(new PVector(mouseX, mouseY), PVector.mult(PVector.add(s.position, s.inputs.get(i)), globalScale)) < (12*globalScale)) {
                if (editing != null){
                  s.connections_in[i] = new Connection(editing, outputIndex);
                  editing.connections_out.add(s);
                  s.calculatePowered();
                }
                else if(s.connections_in[i] != null) {
                  s.connections_in[i].connector.connections_out.remove(s);
                  s.connections_in[i] = null;
                  s.calculatePowered();
                }
                editing = null;
                outputIndex = -1;
                break;
              }
            }
            if (outputIndex == -1 && editing != null) break;
          }
        }
      }

    if (outputIndex == -2 && mouseY >= height-80 && mouseX >= 80) {
      if (editing.type == "custom") {
        for(int i = customGates.size()-1; i >= 0; i --){
          if(customGates.get(i) == editing) customGates.get(i).delete(true);
        }
        customGates.remove(editing);
      } else {
        gates.remove(editing);
      }
      for (Gate s : gates) {
        s.updateConnections();
      }
      for(CustomGate cg : customGates){
        for(Gate g : cg.localGates){
          if (g == editing){
           cg.localGates.remove(editing);
           break;
          }
        }
      }
      for(int i = customGates.size()-1; i >= 0; i--){
       if(customGates.get(i).localGates.size() <= 1) customGates.get(i).delete(false);
      }
    } else {
      for(CustomGate cg : customGates){
        cg.checkGates();
      }
    }
    if (outputIndex != -1) {
      editing = null;
      outputIndex = -1;
    }
  }
  shouldDraw = true;
}

void mouseDragged() {
  if (!creatingCustom){
    if (outputIndex == -2) {
      editing.position = PVector.add(editing.position, PVector.div(new PVector(mouseX - pmouseX, mouseY - pmouseY), globalScale));
      if(editing.type == "custom"){
        for(CustomGate cg : customGates){
          if(editing == cg){
           for(Gate g : cg.localGates){
             g.position = PVector.add(g.position, PVector.div(new PVector(mouseX - pmouseX, mouseY - pmouseY), globalScale));
           }
           break;
          }
        }
      }
    } else if (mouseX > 80 && outputIndex == -1) {
      PVector movedBy = PVector.div(new PVector(mouseX - pmouseX, mouseY - pmouseY), globalScale);
      globalOffset = PVector.add(globalOffset, movedBy);
      for (Gate s : gates) {
        s.position = PVector.add(s.position, movedBy);
      }
       for (CustomGate cg : customGates) {
        cg.position = PVector.add(cg.position, movedBy);
      }
    }
  }
  shouldDraw = true;
}

void mouseClicked() {
  for (Gate s : gates) {
    if((s.hidden == false || s.type == "INPUTbp" || s.type == "OUTPUTbp") && s.position.x > -100 && s.position.x < (width+20)/globalScale && s.position.y > -100 && s.position.y < (height+20)/globalScale){
      if (pixelInPoly(s.shapes.get(0).points, PVector.sub(new PVector(mouseX, mouseY), PVector.mult(s.position, globalScale))) && s.type == "INPUT") {
        s.powered = !s.powered;
        s.calculatePowered();
      }
    }
  }
  
  creatingCustom = false;
  outputIndex = 0;
  if(mouseX >= 90 && mouseX <= 130 && mouseY >= 5 && mouseY <= 45) creatingCustom = true;
  if(mouseX >= 140 && mouseX <= 170 && mouseY >= 5 && mouseY <= 45) outputIndex = -3;
  if(mouseX >= 190 && mouseX <= 230 && mouseY >= 5 && mouseY <= 45){
    if(globalLines == "l turn line") globalLines = "stright";
    else if(globalLines == "stright") globalLines = "stright spline";
    else if(globalLines == "stright spline") globalLines = "spline";
    else if(globalLines == "spline") globalLines = "l turn line";
  }
  if(mouseX >= 240 && mouseX <= 270 && mouseY >= 5 && mouseY <= 45) outputIndex = -4;
  if(mouseX >= 290 && mouseX <= 330 && mouseY >= 5 && mouseY <= 45) outputIndex = -5;
  if(mouseX >= 340 && mouseX <= 370 && mouseY >= 5 && mouseY <= 45) outputIndex = -6;
  
  shouldDraw = true;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(mouseX > 80) {
    globalScale = max(0.5,min(5,globalScale-(e/10)));
  } else {
    if (e == -1 && (height < buttons.size()*85+15 ? buttons.get(buttons.size()-1).position.y > height - 70 : buttons.get(0).position.y > 15)){
      for (Button b : buttons) {
        b.position.y += e*25;
      }
    }
    if (e == 1 && (height < buttons.size()*85+15 ? buttons.get(0).position.y < 15 : buttons.get(buttons.size()-1).position.y < height - 90)) {
      for (Button b : buttons) {
        b.position.y += e*25;
      }
    }
  }
  shouldDraw = true;
}

void drawBackground(){
  stroke(20,60,200,100);
  strokeWeight(1*globalScale);
  for(int x = -40; x <= width+40; x+=20*globalScale){
    line(x+((globalOffset.x*globalScale)%(20*globalScale)),-20+((globalOffset.y*globalScale)%(20*globalScale)),x+((globalOffset.x*globalScale)%(20*globalScale)),height+20+((globalOffset.y*globalScale)%(20*globalScale)));
  }
  for(int y = -40; y <= height+40; y+=20*globalScale){
    line(-20-((globalOffset.x*globalScale)%(20*globalScale)),y+((globalOffset.y*globalScale)%(20*globalScale)),width+20-((globalOffset.x*globalScale)%(20*globalScale)),y+((globalOffset.y*globalScale)%(20*globalScale)));
  }
  updates[0] += 1;
  updates[3] += 1;
  shouldDraw = true;
}
