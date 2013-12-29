void initLightSource()
{
  candle_sprite = loadImage("sprite_candle.png");
  cacheLightSource(); // Generate image array for our candles
  lightsources = new ArrayList<LightMap>(); // Initialize light source location array

  for (int i = 0; i < light_num; i++) {
    int[] rand_pos = randomGridPos(); // Random light location
    LightMap lightsrc = new LightMap(float(rand_pos[0]), float(rand_pos[1]), rand_pos[0], rand_pos[1], lightsrc_rad);
    lightsources.add(lightsrc);
  }
}

void updateLightSource()
{  
  tilemapcache.loadPixels(); // Load cached tilemap
  tilemap = tilemapcache.get(0, 0, tilemapcache.width, tilemapcache.height);
  tilemap.loadPixels(); // Load tilemap to be processed

  for (LightMap lightsrc: lightsources) { // Go through each light source
    lightsrc.processAgentShadow(); // Update shadow based on the manager's location ;)
    lightsrc.processCompanionShadow(); // Update shadow based on light companion location
    
    // Get area affected by light
    PImage lighting = createImage(lightsrc.w*t_size, lightsrc.h*t_size, RGB);
    lighting = tilemap.get(lightsrc.x*t_size, lightsrc.y*t_size, lightsrc.w*t_size, lightsrc.h*t_size);
    
    for (int j = 0; j < lighting.height; j++ ) {
      for (int i = 0; i < lighting.width; i++) {
        // Do not process area outside of view
        if (i*s_size + (lightsrc.x - pos_x)*local2world >= 0 && i*s_size + (lightsrc.x - pos_x)*local2world <= width &&
            j*s_size + (lightsrc.y - pos_y)*local2world >= 0 && j*s_size + (lightsrc.y - pos_y)*local2world <= height) {
          // Process light from each lightsource
          //float max_dist = lightsrc.rad*local2world; // Light radius
          //float d = dist(i*s_size - pos_x*local2world, j*s_size - pos_y*local2world,
          //              (lightsrc.cx - lightsrc.x - pos_x)*local2world, (lightsrc.cy - lightsrc.y - pos_y)*local2world); // Calculate distance in world coordinate
          float max_dist2 = (lightsrc.rad*local2world)*(lightsrc.rad*local2world); // Light radius
          PVector v1 = new PVector(i*s_size - pos_x*local2world, j*s_size - pos_y*local2world);
          PVector v2 = new PVector((lightsrc.cx - lightsrc.x - pos_x)*local2world, (lightsrc.cy - lightsrc.y - pos_y)*local2world);
          float d2 = dist2(v1, v2); // Calculate distance in world coordinate
  
          if (d2 < max_dist2) { // If within radius
            if (grid[(i/t_size + lightsrc.x) + (j/t_size + lightsrc.y)*g_width] != 0) { // If not a block
              if (!shaded(lightsrc, i*s_size + (lightsrc.x - pos_x)*local2world, j*s_size + (lightsrc.y - pos_y)*local2world)) {
                int p_index = i + j*lighting.width;
                color result = color(lighting.pixels[p_index]); // Get original color
                color light = color(50, 50, 50); // Light
                result = blendColor(result, light, SCREEN); // Blend light
                
                // Constrain RGB to make sure they are within 0-255 color range
                float r = red(result); float g = green(result); float b = blue(result);
                constrain(r, 0, 255); constrain(g, 0, 255); constrain(b, 0, 255);
                result = color(r, g, b);
                tilemap.pixels[(i + lightsrc.x*t_size) + (j + lightsrc.y*t_size)*tilemap.width] = result; // Update tilemap with new lighted color
              }
            }
          }
        }
      }
    }
  }
  // Update tilemap
  tilemap.updatePixels();
}

boolean shaded(LightMap lightsrc, float ptx, float pty)
{
  // Process block shadows
  for (ShadowMap shade: lightsrc.shadows) {
    if (inPoly(shade.vert, ptx, pty)) {
      return true;
    }
  }
  // Process the manager's shadow ;)
  for (ShadowMap ashade: lightsrc.agentshadows) {
    if (inPoly(ashade.vert, ptx, pty)) {
      return true;
    }
  }
  // Process the light companion's shadow
  for (ShadowMap cshade: lightsrc.companionshadows) {
    if (inPoly(cshade.vert, ptx, pty)) {
      return true;
    }
  }
  return false; 
}

boolean inPoly(PVector vert[], float x, float y)
{
  // Check if point is in polygon
  int i, j;
  boolean c = false;
  for (i = 0, j = vert.length - 1; i < vert.length; j = i++) {
    if ((((vert[i].y <= y) && (y < vert[j].y)) || ((vert[j].y <= y) && (y < vert[i].y))) && (x < (vert[j].x - vert[i].x)*(y - vert[i].y)/(vert[j].y - vert[i].y) + vert[i].x)) c = !c;
  }
  return c;
}

boolean edgeCastShadow(PVector lt, PVector start, PVector end)
{
  // Determine if the edge should cast shadow
  PVector s2e = new PVector(end.x, end.y);
  s2e.sub(start);
  // Get normal of the vector that goes from the start to the end of the line
  PVector s2e_normal = new PVector(s2e.y, -1*s2e.x);
  // Vector that goes from the light source to the start of the line
  PVector lt2s = new PVector(start.x, start.y);
  lt2s.sub(lt);
  // Determin if the light source is on the left or right side
  if (s2e_normal.dot(lt2s) < 0) return false;
  return true;
}

float dist2(PVector v1, PVector v2)
{
  return ((v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y) + (v1.z - v2.z)*(v1.z - v2.z));
}

void cacheLightSource()
{
  flicker = new PImage[1*frame_count];
  candle_sprite.loadPixels();
  
  // Store candle sprite
  for (int i = 0; i < frame_count; i++) {
    flicker[i] = candle_sprite.get((i/4)*16, 0, 16, 16);
  }
}

void renderLightSource()
{
  // Render each light source
  for (LightMap lightsrc: lightsources) {
    image(flicker[frameCount%frame_count], (lightsrc.idx - pos_x)*local2world, (lightsrc.idy - pos_y)*local2world, local2world, local2world);
  }
}

void renderLight()
{
  // Render light bounding box
  for (LightMap lightsrc: lightsources) lightsrc.render();
}

void renderShadow()
{
  for (LightMap lightsrc: lightsources) {
    for (ShadowMap shade: lightsrc.shadows) {
      shade.render();
    }
  }
}

class LightMap {
  int x; // Lighted area x in local coordinate
  int y; // Lighted area y in local coordinate
  int w; // Lighted area width in local coordinate
  int h; // Lighted area height in local coordinate
  float rad; // Radius in local coordinate
  int idx; // Index x of light source
  int idy; // Index y of light source
  float cx; // Center x in local coordinate
  float cy; // Center y in local coordinate
  PVector cworld; // Light source center in world coordinate
  ArrayList<ShadowMap> shadows; // Shadow
  ArrayList<ShadowMap> agentshadows; // Manager's shadow ;)
  ArrayList<ShadowMap> companionshadows; // Companion shadow
  float life;
  float ambition;
  
  LightMap(float wx, float wy, int id_x, int id_y, float light_rad)
  {
    idx = id_x; // Index x on grid
    idy = id_y; // Index y on grid
    x = idx - ceil(light_rad); // Light boundary x on grid
    y = idy - ceil(light_rad); // Light boundary y on grid
    
    // Bounding shadow to grid
    if ((x + w) > g_width - 1) w = g_width - x;
    if ((y + h) > g_height - 1) h = g_height - y;
    if (x < 0) { w += x; x = 0; }
    if (y < 0) { h += y; y = 0; }
    
    rad = light_rad; // Radius
    w = 2*ceil(rad) + 1; // Make sure width contains all lighted cells
    h = 2*ceil(rad) + 1; // Make sure height contains all lighted cells
    cx = wx + 0.5; // Cell center
    cy = wy + 0.5; // Cell center
    cworld = new PVector((cx - pos_x)*local2world, (cy - pos_y)*local2world);
    
    life = light_rad; // Max energy
    ambition = 0.0005; // Initial darkening speed
    
    processShadow(); // Create shadow map for the light source
    processAgentShadow(); // Create shadow for the manager ;)
    processCompanionShadow(); // Create shadow for the companion
  }
  
  void update()
  {
    cworld = new PVector((cx - pos_x)*local2world, (cy - pos_y)*local2world);
    for (ShadowMap shade: shadows) shade.update(); // Update light source locations
    for (ShadowMap ashade: agentshadows) ashade.update(); // Update manager's shadow ;)
    for (ShadowMap cshade: companionshadows) cshade.update(); // Update companion's shadow
    
    if (rad <= 0) rad = 0; // Darkness
    else rad -= ambition; // Losing energy
  }
  
  void processShadow()
  {
    shadows = new ArrayList<ShadowMap>();
    float max_dist = rad*local2world; // Companion light radius
    
    for (AABB wall: blocks) {
      if (dist(cworld.x, cworld.y, wall.x, wall.y) < max_dist ||
          dist(cworld.x, cworld.y, wall.x + wall.w, wall.y) < max_dist ||
          dist(cworld.x, cworld.y, wall.x, wall.y + wall.h) < max_dist ||
          dist(cworld.x, cworld.y, wall.x + wall.w, wall.y + wall.h) < max_dist) { // If block is within light radius
        ShadowMap shade;
        // Determine which of the four sides should cast shadow
        if (edgeCastShadow(cworld, wall.pt1, wall.pt2)) {
          shade = new ShadowMap(cworld, wall.pt1, wall.pt2, rad);
          shadows.add(shade);
        }
        if (edgeCastShadow(cworld, wall.pt2, wall.pt3)) {
          shade = new ShadowMap(cworld, wall.pt2, wall.pt3, rad);
          shadows.add(shade);
        }
        if (edgeCastShadow(cworld, wall.pt3, wall.pt4)) {
          shade = new ShadowMap(cworld, wall.pt3, wall.pt4, rad);
          shadows.add(shade);
        }
        if (edgeCastShadow(cworld, wall.pt4, wall.pt1)) {
          shade = new ShadowMap(cworld, wall.pt4, wall.pt1, rad);
          shadows.add(shade);
        }
      }
    }
  }
  
  void processAgentShadow()
  {
    agentshadows = new ArrayList<ShadowMap>();
    
    float max_dist = rad*local2world; // Companion light radius
    if (dist(cworld.x, cworld.y, agentAABB.x, agentAABB.y) < max_dist ||
        dist(cworld.x, cworld.y, agentAABB.x + agentAABB.w, agentAABB.y) < max_dist ||
        dist(cworld.x, cworld.y, agentAABB.x, agentAABB.y + agentAABB.h) < max_dist ||
        dist(cworld.x, cworld.y, agentAABB.x + agentAABB.w, agentAABB.y + agentAABB.h) < max_dist) { // If block is within light radius
      ShadowMap shade;
      // Determine which of the four sides should cast shadow
      if (edgeCastShadow(cworld, agentAABB.pt1, agentAABB.pt2)) {
        shade = new ShadowMap(cworld, agentAABB.pt1, agentAABB.pt2, rad);
        agentshadows.add(shade);
      }
      if (edgeCastShadow(cworld, agentAABB.pt2, agentAABB.pt3)) {
        shade = new ShadowMap(cworld, agentAABB.pt2, agentAABB.pt3, rad);
        agentshadows.add(shade);
      }
      if (edgeCastShadow(cworld, agentAABB.pt3, agentAABB.pt4)) {
        shade = new ShadowMap(cworld, agentAABB.pt3, agentAABB.pt4, rad);
        agentshadows.add(shade);
      }
      if (edgeCastShadow(cworld, agentAABB.pt4, agentAABB.pt1)) {
        shade = new ShadowMap(cworld, agentAABB.pt4, agentAABB.pt1, rad);
        agentshadows.add(shade);
      }
    }
  }
  
  void processCompanionShadow()
  {
    companionshadows = new ArrayList<ShadowMap>();
    
    float max_dist = rad*local2world; // Companion light radius
    if (dist(cworld.x, cworld.y, lc.laabb.x, lc.laabb.y) < max_dist ||
        dist(cworld.x, cworld.y, lc.laabb.x + lc.laabb.w, lc.laabb.y) < max_dist ||
        dist(cworld.x, cworld.y, lc.laabb.x, lc.laabb.y + lc.laabb.h) < max_dist ||
        dist(cworld.x, cworld.y, lc.laabb.x + lc.laabb.w, lc.laabb.y + lc.laabb.h) < max_dist) { // If block is within light radius   
      ShadowMap shade;
      // Determine which of the four sides should cast shadow
      if (edgeCastShadow(cworld, agentAABB.pt1, agentAABB.pt2)) {
        shade = new ShadowMap(cworld, lc.laabb.pt1, lc.laabb.pt2, rad);
        agentshadows.add(shade);
      }
      if (edgeCastShadow(cworld, agentAABB.pt2, agentAABB.pt3)) {
        shade = new ShadowMap(cworld, lc.laabb.pt2, lc.laabb.pt3, rad);
        agentshadows.add(shade);
      }
      if (edgeCastShadow(cworld, agentAABB.pt3, agentAABB.pt4)) {
        shade = new ShadowMap(cworld, lc.laabb.pt3, lc.laabb.pt4, rad);
        agentshadows.add(shade);
      }
      if (edgeCastShadow(cworld, agentAABB.pt4, agentAABB.pt1)) {
        shade = new ShadowMap(cworld, lc.laabb.pt4, lc.laabb.pt1, rad);
        agentshadows.add(shade);
      }
    }
  }
  
  void render()
  {
    // Light map
    noFill();
    stroke(255, 204, 0);
    rect((x - pos_x)*local2world, (y - pos_y)*local2world, w*local2world, h*local2world);
    stroke(204, 102, 0);
    rect((floor(cx) - pos_x)*local2world, (floor(cy) - pos_y)*local2world, local2world, local2world);
    // Life bar
    fill(255, 0, 0);
    stroke(255, 0, 0);
    rect((floor(cx) - pos_x)*local2world, (ceil(cy) - 0.1 - pos_y)*local2world, local2world, 0.02*local2world);
    fill(0, 255, 0);
    stroke(0, 255, 0);
    rect((floor(cx) - pos_x)*local2world, (ceil(cy) - 0.1 - pos_y)*local2world, (rad/life)*local2world, 0.02*local2world);
  }  
}

class ShadowMap {
  PVector p1;
  PVector p2;
  PVector p3;
  PVector p4;
  PVector[] vert; // Vertices of the four points that make up the shadow
  float offsetx; // Offset for scrolling update
  float offsety; // Offset for scrolling update
  float rad;
  
  ShadowMap(PVector src, PVector pt1, PVector pt2, float r)
  {
    offsetx = pos_x;
    offsety = pos_y;
    rad = r;
    
    p1 = pt1;
    p2 = projectPoint(src, pt1);
    p3 = projectPoint(src, pt2);
    p4 = pt2;
    
    vert = new PVector[4];
    vert[0] = new PVector(p1.x, p1.y);
    vert[1] = new PVector(p2.x, p2.y);
    vert[2] = new PVector(p3.x, p3.y);
    vert[3] = new PVector(p4.x, p4.y);
  }
  
  PVector projectPoint(PVector lt, PVector pt)
  {
    // Vector from light to point
    PVector lt2pt = new PVector(pt.x, pt.y);
    lt2pt.sub(lt);
    
    // Length from point to edge of light radius
    float extraLength = (rad + 1)*local2world - lt2pt.mag();
    PVector extra = new PVector(lt2pt.x, lt2pt.y);
    extra.normalize();
    extra.mult(extraLength);
    
    // Stretch shadow from point to a bit beyond light radius
    PVector pjpt = new PVector(pt.x, pt.y);
    pjpt.add(extra);
    return pjpt;    
  }
  
  void update()
  {
    vert[0] = new PVector((p1.x) - (pos_x - offsetx)*local2world, (p1.y) - (pos_y - offsety)*local2world);
    vert[1] = new PVector((p2.x) - (pos_x - offsetx)*local2world, (p2.y) - (pos_y - offsety)*local2world);
    vert[2] = new PVector((p3.x) - (pos_x - offsetx)*local2world, (p3.y) - (pos_y - offsety)*local2world);
    vert[3] = new PVector((p4.x) - (pos_x - offsetx)*local2world, (p4.y) - (pos_y - offsety)*local2world);
  }
  
  void render()
  {
    // Shadow map
    noFill();
    stroke(42, 106, 105);
    quad(vert[0].x, vert[0].y, vert[1].x, vert[1].y, vert[2].x, vert[2].y, vert[3].x, vert[3].y);
  }
}
