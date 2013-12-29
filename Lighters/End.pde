void initEnd()
{
  stars_sprite = loadImage("sprite_stars.png");
  end_sprite = loadImage("sprite_end.png");
  end_sprite.loadPixels();
  bng = new PImage[6];
  
  bng[0] = end_sprite.get(1*48, 1*48, 48, 48);
  bng[1] = end_sprite.get(0*48, 2*48, 48, 48);
  bng[2] = end_sprite.get(1*48, 2*48, 48, 48);
  bng[3] = end_sprite.get(0*48, 1*48, 48, 48);
  bng[4] = end_sprite.get(0*48, 0*48, 48, 48);
  bng[5] = end_sprite.get(1*48, 0*48, 48, 48);
}

void endLighters()
{
  switch (ending) {
    case 1: { // The darkness...
      count++;
      step.pause();
      updateLightCompanion();
      background(0);
      tilemapcache.loadPixels();
      tilemap = tilemapcache.get(0, 0, tilemapcache.width, tilemapcache.height);
      tint(255 - float(count)*0.5);
      renderTileMap();
      tint(255);
      image(walk[2*frame_count], width*0.5 - 0.5*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      renderLightCompanion();
      if (count >= 510) {
        count = 0;
        ending = 2;      
      }
      break;
    }
    case 2: { // Is this the end?
      count++;
      updateLightCompanion();
      background(0);
      if (count > 0 && count <= 100) image(bng[0], width*0.5 - 0.5*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      if (count > 100 && count <= 200) image(bng[1], width*0.5 - 0.5*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      if (count > 200) image(bng[2], width*0.5 - 0.5*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      renderLightCompanion();
      if (count >= 600) {
        count = 0;
        ending = 3;      
      }
      break;
    }
    case 3: { // Nothingness...
      updateLightCompanion();
      background(0);
      renderLightCompanion();
      image(bng[2], width*0.5 - 0.5*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      if (lc.miracle) { // I've always been here for you
        ending = 4;      
      }
      break;
    }
    case 4: { // This one's for you and me
      count++;
      background(0);
      tint(255, count/4);
      image(bng[3], width*0.5 - 0.8*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
      tint(255, 255);
      image(bng[2], width*0.5 - 0.5*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      if (count >= 1020) {
        song.loop();
        count = 0;
        ending = 5;      
      }
      break;
    }
    case 5: { // living out our dreams
      count++;
      background(0);
      if (count > 0 && count <= 100) {
        image(bng[3], width*0.5 - 0.8*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
        image(bng[2], width*0.5 - 0.5*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      }
      if (count > 100 && count <= 250) {
        image(bng[3], width*0.5 - 0.8*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
        image(bng[1], width*0.5 - 0.5*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      }
      if (count > 250 && count <= 350) {
        image(bng[3], width*0.5 - 0.8*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
        image(bng[0], width*0.5 - 0.4*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      }
      if (count > 350 && count <= 550) {
        image(bng[3], width*0.5 - 0.8*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
        image(bng[5], width*0.5 - 0.4*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      }
      if (count > 550 && count <= 650) {
        image(bng[4], width*0.5 - 0.9*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
        image(bng[5], width*0.5 - 0.4*local2world, height*0.5 - 0.5*local2world, local2world, local2world);
      }
      if (count > 650 && count <= 750) {
        image(bng[4], width*0.5 - 1.0*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
        image(bng[5], width*0.5 - 0.4*local2world, height*0.5 - 0.55*local2world, local2world, local2world);
      }
      if (count > 750 && count <= 850) {
        image(bng[5], width*0.5 - 0.4*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
        image(bng[4], width*0.5 - 1.1*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
      }
      if (count > 850) {
        image(bng[5], width*0.5 - 0.4*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
        image(bng[4], width*0.5 - 1.1*local2world, height*0.5 - 0.6*local2world, local2world, local2world);
        count = 0;
        ending = 6;      
      }
      break;
    }
    case 6: { // We're all right where we should be
      count++;
      background(0);
      if (count > 0 && count <= 520) { // Lift my arms out wide I open my eyes
        tint(min(0 + count*0.5, 255));
        image(stars_sprite, 0, 0, width, height);
        tint(255);
        smooth();
        noStroke();
        starfield();
        noSmooth();
        image(bng[5], width*0.5 - 0.4*local2world, height*0.5 - 0.6*local2world + (float(count)*0.005)*local2world, local2world, local2world);
        image(bng[4], width*0.5 - 1.1*local2world, height*0.5 - 0.6*local2world + (float(count)*0.005)*local2world, local2world, local2world);
      }
      if (count > 520 && count <= 570) { // And now all I wanna see
        image(stars_sprite, 0, 0, width, height);
        smooth();
        noStroke();
        starfield();
        noSmooth();
        image(bng[5], width*0.5 - 0.4*local2world, height*0.5 + 2.0*local2world, local2world, local2world);
        image(bng[4], width*0.5 - 1.1*local2world, height*0.5 + 2.0*local2world, local2world, local2world);
      }
      if (count > 570) { // Is a sky full of lighters
        image(stars_sprite, 0, 0, width, height);
        smooth();
        noStroke();
        starrynight = false;
        star_num = 200;
        starfield();
        shootingstar(100);
        noSmooth();
        image(bng[5], width*0.5 - 0.4*local2world, height*0.5 + 2.0*local2world, local2world, local2world);
        image(bng[4], width*0.5 - 1.1*local2world, height*0.5 + 2.0*local2world, local2world, local2world);
        count = 0;
        ending = 7;      
      }
      break;
    }
    case 7: { // A sky full of lighters
      image(stars_sprite, 0, 0, width, height);
      smooth();
      noStroke();
      starfield();
      shootingstar(3);
      noSmooth();
      image(bng[5], width*0.5 - 0.4*local2world, height*0.5 + 2.0*local2world, local2world, local2world);
      image(bng[4], width*0.5 - 1.1*local2world, height*0.5 + 2.0*local2world, local2world, local2world);
      break;
    }
  }
}

void starfield()
{
  if (!starrynight) {
    stars = new PVector[star_num];
    for (int i = 0; i < star_num; i++) {
      stars[i] = new PVector(random(width), random(0, height*3/4), random(.1, 2.5));
    }
    starrynight = true;
  }
  if (starrynight) {
    for (int i = 0; i < star_num; i++) {
      int c = int(random(250, 255));
      star(stars[i].x, stars[i].y, stars[i].z, color(c, c, c));
    }
  }
}

void star(float x, float y, float r, color c){
  fill(c*2, random(16, 64));
  for (int i = 0; i < random(3, 5); i++) streak(x, y, random(3*r, 5*r), 1, random(TWO_PI));
  fill(c, random(16, 255));
  ellipse(x, y, r, r);
}
  
void streak(float x, float y, float w, float h, float a){
  pushMatrix();
  translate(x, y);
  rotate(a);
  triangle(-w/2, 0, 0, h/2 , 0, -h/2);
  triangle(w/2, 0, 0, h/2 , 0, -h/2);
  popMatrix();
}

void shootingstar(int rate)
{
  if (!makeawish) {
    meteor = new PVector[meteo_num];
    if (int(random(100)) > (100 - rate)) {
      for (int i = 0; i < meteo_num; i++) meteor[i] = new PVector(0, 0);
      start = new PVector(random(width*2/3, width), random(0, height/3));
      PVector end = new PVector(random(0, width/3), random(height/3, height*2/3));
      delta = new PVector((end.x - start.x)/meteo_num, (end.y - start.y)/meteo_num);
      timer = 0;
      msize = 5;
      for (int i = 0; i < meteo_num; i++) meteor[i].set(start);
      makeawish = true;
    }
  }
  if (makeawish) {
    for (int i = 0; i < meteo_num - 1; i++) {
      int ssize = max(0, int(msize*i/meteo_num));
      if (ssize > 0) {
        strokeWeight(ssize*0.5);
        stroke(255);
      }
      else noStroke();
      line(meteor[i].x, meteor[i].y, meteor[i + 1].x, meteor[i + 1].y);
    }
    msize *= 0.9;
    for (int i = 0; i < meteo_num - 1; i++) meteor[i].set(meteor[i + 1]);
    if (timer >= 0 && timer < meteo_num) {
      meteor[meteo_num - 1].set((start.x + delta.x*(timer)), (start.y + delta.y*(timer)), 0);
      timer++;
      if (timer >= meteo_num) {
        timer = -1;
        makeawish = false;
      }
    }
  }
}
