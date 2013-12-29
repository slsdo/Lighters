void initCompanion()
{
  companion_sprite = loadImage("sprite_companion.png");
  cacheCompanion(); // Generate image array for companion
  lc = new LightCompanion();
}

void updateLightCompanion()
{
  lc.update(); // Render light companion
  
  if (flash) {
    tilemap.loadPixels(); // Load tilemap to be processed
    
    for (int i = 0; i < tilemap.width; i++) {
      for (int j = 0; j < tilemap.height; j++ ) {
        // Do not process area outside of view
        if (i*s_size + lc.lmap.x - pos_x*local2world >= 0 && i*s_size + lc.lmap.x - pos_x*local2world <= width &&
            j*s_size + lc.lmap.y - pos_y*local2world >= 0 && j*s_size + lc.lmap.y - pos_y*local2world <= height) {
          //float max_dist = lightc_rad*local2world; // Light radius
          //float d = dist(i*s_size - pos_x*local2world, j*s_size - pos_y*local2world, lc.x, lc.y); // Calculate distance in world coordinate
          float max_dist2 = (lc.hope*local2world)*(lc.hope*local2world); // Light radius
          PVector v1 = new PVector(i*s_size - pos_x*local2world, j*s_size - pos_y*local2world);
          PVector v2 = new PVector(lc.x, lc.y);
          float d2 = dist2(v1, v2); // Calculate in scaled world coordinate
          
          if (d2 < max_dist2 && (grid[lc.idx + lc.idy*g_width] != 0 || finale)) { // If within radius and is not on top of a block
            if (grid[(i/t_size) + (j/t_size)*g_width] != 0) {  // If not a block
              if (!shaded(lc.lmap, i*s_size + lc.lmap.x - pos_x*local2world, j*s_size + lc.lmap.y - pos_y*local2world) || finale) {
                int p_index = i + j*tilemap.width;
                color result = color(tilemap.pixels[p_index]); // Get original color
                color light = color(100, 100, 100); // Light
                result = blendColor(result, light, SCREEN); // Blend light
                
                // Constrain RGB to make sure they are within 0-255 color range
                float r = red(result); float g = green(result); float b = blue(result);
                constrain(r, 0, 255); constrain(g, 0, 255); constrain(b, 0, 255);
                result = color(r, g, b);
                tilemap.pixels[p_index] = result; // Update tilemap with new lighted color
              }
            }
          }
        }
      }
    }
    // Update tilemap
    tilemap.updatePixels();
  }
}

void cacheCompanion()
{
  shine = new PImage[1*frame_count];
  companion_sprite.loadPixels();
  
  // Store companion sprite
  for (int i = 0; i < frame_count; i++) {
    shine[i] = companion_sprite.get((i/4)*16, 0, 16, 16);
  }
}

void renderLightCompanion()
{
  // Render the light companion
  image(shine[frameCount%frame_count], lc.x - 0.5*local2world, lc.y - 0.5*local2world, local2world, local2world);
}

void renderCompanionInfo()
{
  lc.render(); // Info
  // Light and shadow maps
  if (flash) {
    noFill();
    stroke(255, 204, 0);
    rect((lc.lmap.x - pos_x)*local2world, (lc.lmap.y - pos_y)*local2world, lc.lmap.w*local2world, lc.lmap.h*local2world);
    stroke(204, 102, 0);
    rect((floor(lc.lmap.cx) - pos_x)*local2world, (floor(lc.lmap.cy) - pos_y)*local2world, local2world, local2world);
    
    for (ShadowMap shade: lc.lmap.shadows) {
      shade.render();
    }
    for (ShadowMap shade: lc.lmap.agentshadows) {
      shade.render();
    }
  }
}

class LightCompanion { 
  float x; // Location x
  float y; // Location y
  float speed; // Hovering speed
  float offsetx; // Brownian motion x
  float offsety; // Brownian motion y
  int idx; // Current index x
  int idy; // Current index y
  float shadex; // Dynamic shadow x
  float shadey; // Dynamic shadow y
  AABB laabb; // Collision body
  LightMap lmap; // Light map
  float hope; // Light energy
  boolean miracle; // This can't be...
  
  LightCompanion()
  {
    x = width*0.5 + 0.3*local2world;
    y = height*0.5 - 0.5*local2world;
    offsetx = random(-10, 10);
    offsety = random(-10, 10);
    laabb = new AABB(x, y, 0.1*local2world, 0.2*local2world, int(g_width*0.5), int(g_height*0.5));
    idx = int(pos_x + (x)*world2local + 0.8);
    idy = int(pos_y + (y)*world2local + 0.0);
    hope = lightc_rad;
    miracle = false;
  }
  
  void update()
  {
    seek(); // Look for light
    
    // Update position
    x += ((width*0.5 + offsetx - 0.5*local2world) - x)/speed;
    y += ((height*0.5 + offsety - 0.5*local2world) - y)/speed;
    idx = int(pos_x + x*world2local);
    idy = int(pos_y + y*world2local);
    
    // Update collision box
    laabb.update(x, y);
    laabb.idx = idx;
    laabb.idy = idy;
    
    if (ending == 0) {
      if (flash && hope > 0) hope -= 0.001;
      if (hope <= 0) flash = false;
      if (!flash && hope < lightc_rad) hope += 0.01;
      if (lightsources.size() == 0 && !finale) {
        finale = true;
        flash = true;
        hope = lightc_rad;
      }
      
      // Update light map
      if (flash) {
        lmap = new LightMap(pos_x + x*world2local - 0.5, pos_y + y*world2local - 0.5, idx, idy, hope);  
        lmap.agentshadows.clear(); // No need for now
        lmap.companionshadows.clear(); // Not needed
      }

      if (finale && !flash) {
        finale = false;
        ending = 1;
      }
    }
  }
  
  void seek()
  {
    if (ending != 3) {
      if (lightsources.size() > 0) {
        // Look for closest light within range
        float max_dist2 = (lightc_rad*local2world)*(lightc_rad*local2world); // Light radius
        PVector v_lc = new PVector(x, y);
        PVector v_agent = new PVector(width*0.5, height*0.5);
        float d2min = 10000.0;
        int d2id = 0;
        
        for (int i = 0; i < lightsources.size(); i++) {
          LightMap lightsrc = (LightMap) lightsources.get(i);
          PVector v_ltsrc = new PVector(lightsrc.cworld.x, lightsrc.cworld.y);
          float d2 = dist2(v_agent, v_ltsrc); // Calculate distance in world coordinate
          
          if (d2 < d2min) {
            d2min = d2;
            d2id = i;
          }
        }
        
        LightMap lightsrc = (LightMap) lightsources.get(d2id);
        PVector v_ltsrc = new PVector(lightsrc.cworld.x, lightsrc.cworld.y);
        if (d2min < max_dist2 && lightsrc.rad != 0 && hope >= lightc_rad) {
          float arrive = dist2(v_lc, v_ltsrc); // If arrived
          if (arrive < 10.0) { // Refill if arrived
            lightsrc.rad = lightsrc.life;
            lightsrc.ambition += 0.0005;
            hope = 0;
          }
          else { // Move toward target
            offsetx += 0.5*((lightsrc.cx - pos_x)*local2world - x);
            offsety += 0.5*((lightsrc.cy - pos_y)*local2world - y);
            speed = 20;
          }
          return;
        }
      }
      wander(); // If no light within range
    }
    else {
      float d = dist(x, y, width*0.5, height*0.5);
      if (d < 1) {
        miracle = true;
      }
      offsetx += 0.5*(width*0.5 - x);
      offsety += 0.5*(height*0.5 - y);
      speed = 1000;
    }
  }
  
  void wander()
  {
    // Go in a random direction
    offsetx += random(-2, 2);
    offsety += random(-2, 2);    
    if (keys[w]) { offsetx += random(-2, 2); offsety += random(2, 6); }
    if (keys[a]) { offsetx += random(5, 6); offsety += random(-2, 2); }
    if (keys[s]) { offsetx += random(-2, 2); offsety += random(-6, -2); }
    if (keys[d]) { offsetx += random(-6, -2); offsety += random(-2, 2); }
    offsetx = constrain(offsetx, -10, 50);
    offsety = constrain(offsety, -10, 50);
    speed = random(15, 30);
  }
  
  void render()
  {
    // Bounding box
    stroke(0, 102, 153);
    noFill();
    rect(laabb.x, laabb.y, laabb.w, laabb.h);
    // Life bar
    fill(255, 0, 0);
    stroke(255, 0, 0);
    rect(floor(laabb.x - 10), ceil(laabb.y + 10), 0.5*local2world, 0.02*local2world);
    fill(0, 255, 0);
    stroke(0, 255, 0);
    rect(floor(laabb.x - 10), ceil(laabb.y + 10), 0.5*(hope/lightc_rad)*local2world, 0.02*local2world);
    // Attraction
    float max_dist2 = (lightc_rad*local2world)*(lightc_rad*local2world); // Light radius
    PVector v1 = new PVector(width*0.5, height*0.5);
    for (LightMap lightsrc: lightsources) {
      PVector v2 = new PVector(lightsrc.cworld.x, lightsrc.cworld.y);
      float d2 = dist2(v1, v2);
      if (d2 < max_dist2) stroke(0, 0, 255);
      else stroke(255);
      line(v1.x, v1.y, v2.x, v2.y);
    }
  }
}


