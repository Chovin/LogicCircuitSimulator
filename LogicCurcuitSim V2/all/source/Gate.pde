class Gate {
  ArrayList<Shape> shapes = new ArrayList<Shape>();
  boolean outline;
  String type;
  PVector position;
  ArrayList<PVector> inputs = new ArrayList<PVector>();
  ArrayList<PVector> outputs = new ArrayList<PVector>();
  Connection[] connections_in;
  ArrayList<Gate> connections_out = new ArrayList<Gate>();
  Boolean powered = false, hidden = false;
  int powerChecks = 0;

  Gate(String name, PVector pos) {
    this.type = name;
    this.position = pos;
    getShape(name);
    connections_in = new Connection[inputs.size()];
  }


  void show() {
    //Show connecting lines
    for (int i = 0; i < connections_in.length; i++) {
      if ((this.hidden == false || this.type=="INPUTbp") && connections_in[i] != null && (this.position.x > -100 && this.position.x < (width+20)/globalScale && this.position.y > -100 && this.position.y < (height+20)/globalScale || connections_in[i].connector.position.x > -100 && connections_in[i].connector.position.x < (width+20)/globalScale && connections_in[i].connector.position.y > -100 && connections_in[i].connector.position.y < (height+20)/globalScale)) {
        if (connections_in[i].connector.powered) {
          stroke(0, 200, 100);
        } else {
          stroke(255, 20, 50);
        }
        strokeWeight(2*globalScale);
        if(connections_in[i].connector.outputs.size() == 0) {
          connections_in[i] = null;
        } else {
          line(PVector.mult(PVector.add(connections_in[i].connector.position, connections_in[i].connector.outputs.get(connections_in[i].inputIndex)), globalScale), PVector.mult(PVector.add(this.position, new PVector(this.inputs.get(i).x, this.inputs.get(i).y)), globalScale), globalLines, false);
        }
        updates[0] += 1;
        updates[3] += 1;
      }
    }

    if (this.position.x > -100 && this.position.x < (width+20)/globalScale && this.position.y > -100 && this.position.y < (height+20)/globalScale) {
      for (Shape shape : shapes) {
        if (outline) stroke(0);
        else noStroke();

        

        if (type == "OUTPUT" && powered) {
          stroke(0, 150, 80);
          strokeWeight(2*globalScale);
          fill(0, 200, 100);
        } else if (type == "INPUT" && powered) {
          stroke(0, 200, 100);
          strokeWeight(2*globalScale);
          fill(0,200,100);
        } else {
          fill(shape.fill);
        }

        if(!this.hidden){
          beginShape();
          for (PVector point : shape.points) {
            vertex(this.position.x*globalScale + point.x*globalScale, this.position.y*globalScale + point.y*globalScale);
          }
          endShape(CLOSE);
          updates[0] += 1;
          updates[3] += 1;
        }
      }


      if (outline) stroke(0);
      else noStroke();
      strokeWeight(1*globalScale);
      //Show inputs and output connectors
      fill(255);
      for (int i = 0; i < inputs.size(); i ++) {
        if(!hidden || this.type == "INPUTbp") {
          fill(200, 200, 80);
          if (connections_in[i] == null) {
            fill(255, 255, 10);
            ellipse((this.position.x+inputs.get(i).x)*globalScale, (this.position.y+inputs.get(i).y)*globalScale, 6*globalScale, 6*globalScale);
          } else {
            fill(200, 200, 80);
            ellipse((this.position.x+inputs.get(i).x)*globalScale, (this.position.y+inputs.get(i).y)*globalScale, 3*globalScale, 3*globalScale);
          }
          updates[0] += 1;
          updates[3] += 1;
        }
      }

      for (PVector output : outputs) {
        if(!hidden || this.type == "OUTPUTbp") {
          fill(120, 200, 180);
          ellipse((this.position.x+output.x)*globalScale, (this.position.y+output.y)*globalScale, 5*globalScale, 5*globalScale);
          updates[0] += 1;
          updates[3] += 1;
        }
      }
    }
    //Draw any text
    if (type == "INPUT") {
      textSize(12*globalScale);
      textAlign(CENTER,CENTER);
      fill(0);
      text(powered ? "1" : "0",(this.position.x+10)*globalScale,(this.position.y+10)*globalScale);
    }
    this.powerChecks = 0;
  }

  void getShape(String name) {
    switch(name) {
    case "AND":
      this.shapes.add(new Shape(new PVector[]{new PVector(0, 0), new PVector(20, 0), new PVector(30, 5), new PVector(40, 20), new PVector(30, 35), new PVector(20, 40), new PVector(0, 40)}, color(50, 120, 200), false));
      inputs.add(new PVector(0, 10));
      inputs.add(new PVector(0, 30));
      outputs.add(new PVector(40, 20));
      break;
    case "NAND":
      this.shapes.add(new Shape(new PVector[]{new PVector(0, 0), new PVector(20, 0), new PVector(30, 5), new PVector(40, 20), new PVector(30, 35), new PVector(20, 40), new PVector(0, 40)}, color(50, 120, 200), false));
      this.shapes.add(new Shape(new PVector[]{new PVector(40, 20), new PVector(45, 15), new PVector(50, 20), new PVector(45, 25)}, color(50, 120, 200), false));
      inputs.add(new PVector(0, 10));
      inputs.add(new PVector(0, 30));
      outputs.add(new PVector(50, 20));
      break;
    case "NOT":
      this.shapes.add(new Shape(new PVector[]{new PVector(0, 0), new PVector(40, 20), new PVector(0, 40)}, color(50, 120, 200), false));
      this.shapes.add(new Shape(new PVector[]{new PVector(40, 20), new PVector(45, 15), new PVector(50, 20), new PVector(45, 25)}, color(50, 120, 200), false));
      inputs.add(new PVector(0, 20));
      outputs.add(new PVector(50, 20));
      break;
    case "OR":
      this.shapes.add(new Shape(new PVector[]{new PVector(0, 0), new PVector(20, 5), new PVector(30, 10), new PVector(40, 20), new PVector(30, 30), new PVector(20, 35), new PVector(0, 40), new PVector(5, 30), new PVector(5, 10)}, color(50, 120, 200), false));
      inputs.add(new PVector(5, 10));
      inputs.add(new PVector(5, 30));
      outputs.add(new PVector(40, 20));
      break;
    case "NOR":
      this.shapes.add(new Shape(new PVector[]{new PVector(0, 0), new PVector(20, 5), new PVector(30, 10), new PVector(40, 20), new PVector(30, 30), new PVector(20, 35), new PVector(0, 40), new PVector(5, 30), new PVector(5, 10)}, color(50, 120, 200), false));
      this.shapes.add(new Shape(new PVector[]{new PVector(40, 20), new PVector(45, 15), new PVector(50, 20), new PVector(45, 25)}, color(50, 120, 200), false));
      inputs.add(new PVector(5, 10));
      inputs.add(new PVector(5, 30));
      outputs.add(new PVector(50, 20));
      break;
    case "XOR":
      this.shapes.add(new Shape(new PVector[]{new PVector(0, 0), new PVector(20, 5), new PVector(30, 10), new PVector(40, 20), new PVector(30, 30), new PVector(20, 35), new PVector(0, 40), new PVector(5, 30), new PVector(5, 10)}, color(50, 120, 200), false));
      this.shapes.add(new Shape(new PVector[]{new PVector(-5, 0), new PVector(0, 10), new PVector(0, 30), new PVector(-5, 40), new PVector(-2, 30), new PVector(-2, 10)}, color(50, 120, 200), false));
      inputs.add(new PVector(-5, 10));
      inputs.add(new PVector(-5, 30));
      outputs.add(new PVector(40, 20));
      break;
    case "XNOR":
      this.shapes.add(new Shape(new PVector[]{new PVector(0, 0), new PVector(20, 5), new PVector(30, 10), new PVector(40, 20), new PVector(30, 30), new PVector(20, 35), new PVector(0, 40), new PVector(5, 30), new PVector(5, 10)}, color(50, 120, 200), false));
      this.shapes.add(new Shape(new PVector[]{new PVector(-5, 0), new PVector(0, 10), new PVector(0, 30), new PVector(-5, 40), new PVector(-2, 30), new PVector(-2, 10)}, color(50, 120, 200), false));
      this.shapes.add(new Shape(new PVector[]{new PVector(40, 20), new PVector(45, 15), new PVector(50, 20), new PVector(45, 25)}, color(50, 120, 200), false));
      inputs.add(new PVector(-5, 10));
      inputs.add(new PVector(-5, 30));
      outputs.add(new PVector(50, 20));
      break;
    case "INPUT":
      this.shapes.add(new Shape(new PVector[]{new PVector(0, 0), new PVector(0, 20),new PVector(20,20), new PVector(20, 0)}, color(200, 100, 90), false));
      outputs.add(new PVector(20, 10));
      break;
    case "OUTPUT":
      this.shapes.add(new Shape(new PVector[]{new PVector(0, 10), new PVector(20, 0), new PVector(20, 20)}, color(255, 100, 90), false));
      inputs.add(new PVector(0, 10));
      break;
    }
  }

  void calculatePowered() {
    if(this.powerChecks == 5) return;
    switch(this.type) {
    case "AND":
      if (connections_in[0] != null && connections_in[1] != null && connections_in[0].connector.powered && connections_in[1].connector.powered) this.powered = true;
      else powered = false;
      break;
    case "NOT":
      if (connections_in[0] != null && connections_in[0].connector.powered) this.powered = false;
      else powered = true;
      break;
    case "NAND":
      if (connections_in[0] != null && connections_in[1] != null && connections_in[0].connector.powered && connections_in[1].connector.powered) this.powered = false;
      else powered = true;
      break;
    case "OR":
      if (connections_in[0] != null && connections_in[1] != null) {
        if (connections_in[0].connector.powered || connections_in[1].connector.powered) this.powered = true;
        else powered = false;
      }
      break;
    case "NOR":
      if (connections_in[0] != null && connections_in[1] != null) {
        if (connections_in[0].connector.powered || connections_in[1].connector.powered) this.powered = false;
        else powered = true;
      }
      break;
    case "XOR":
      if (connections_in[0] != null && connections_in[1] != null) {
        if ((connections_in[0].connector.powered || connections_in[1].connector.powered) && !(connections_in[0].connector.powered && connections_in[1].connector.powered)) this.powered = true;
        else powered = false;
      }
      break;
    case "XNOR":
      if (connections_in[0] != null && connections_in[1] != null) {
        if ((connections_in[0].connector.powered || connections_in[1].connector.powered) && !(connections_in[0].connector.powered && connections_in[1].connector.powered)) this.powered = false;
        else powered = true;
      }
      break;
    case "OUTPUT":
      if (connections_in[0] != null && connections_in[0].connector.powered) this.powered = true;
      else this.powered = false;
      break;
    case "INPUTbp":
      if (connections_in[0] != null && connections_in[0].connector.powered) this.powered = true;
      else this.powered = false;
      break;
    case "OUTPUTbp":
      if (connections_in[0] != null && connections_in[0].connector.powered) this.powered = true;
      else this.powered = false;
      break;
    }
    this.powerChecks++;
    for (Gate g : connections_out) {
      g.calculatePowered();
    }
    updates[1] += 1;
    updates[3] += 1;
  }

  void updateConnections() {
    for (int i = 0; i < this.connections_in.length; i ++) {
      if (this.connections_in[i] != null) {
        Boolean found = false;
        for (Gate g : gates) {
          if (g == this.connections_in[i].connector) {
            found = true;
            break;
          }
        }
        if (found == false) this.connections_in[i] = null;
      }
    }
  }
}
