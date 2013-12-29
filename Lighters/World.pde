void initWorld()
{
  initGrid(); // Initialize empty grid

  // Generate map
  pcg = new PCG();
  pcg.updateParam(0, 4, 16, 3, 4, 4);
  pcg.generatePCG();
  
  // If rooms are disconnected
  while (!pcg.connected()) {
    initGrid(); // Reset grid
    pcg.generatePCG(); // Generate new map
  }
}

void initGrid()
{
  grid = new byte[g_width*g_height];
  tiles = new byte[g_width*g_height];
  
  for (int j = 0; j < g_height; j++) {
    for (int i = 0; i < g_width; i++) {
      grid[i + j*g_width] = 0; // Initialize all cell as empty
      tiles[i + j*g_width] = byte(random(5)); // Random floor tile
    }
  }
}

void updateWorld()
{
  pos_x += vel_x*world2local; // Update x position in local coordinate
  pos_y += vel_y*world2local; // Update y position in local coordinate
  vel_x = 0; // Reset x velocity
  vel_y = 0; // Reset y velocity
  index_x = int(pos_x + (width*0.5 - 0.5*local2world)*world2local + 0.4); // Update agent index x value in local coordinate
  index_y = int(pos_y + (height*0.5 - 0.5*local2world)*world2local + 0.8); // Update agent index y value in local coordinate
  for (AABB wall: blocks) wall.update((wall.idx - pos_x)*local2world, (wall.idy - pos_y)*local2world); // Update collision body locations
  for (LightMap lightsrc: lightsources) lightsrc.update(); // Update light source locations
  for (int i = 0; i < lightsources.size(); i++) { // Go through each light source and remove dead lights
    LightMap lightsrc = (LightMap) lightsources.get(i);
    if (lightsrc.rad == 0) {
      lightsources.remove(i);
      dusk(100/light_num); // Add darkness
    }
  }
}
  
int[] randomGridPos()
{
  // Random location
  int rand_x = int(random(g_width));
  int rand_y = int(random(g_height));
  
  // If location is not valid
  while (grid[rand_x + rand_y*g_width] == 0) {
    rand_x = int(random(g_width));
    rand_y = int(random(g_height));    
  }
  
  int[] rpos = new int[2];
  rpos[0] = rand_x;
  rpos[1] = rand_y;
  return rpos;
}

void renderInfo()
{
  // Render information
  fill(255);
  text("FPS: " + frameRate, 10, 20);
  text("Grid: " + g_width + "x" + g_height, 10, 35);
  text("Walls: " + blocks.size(), 10, 50);
  text("Position x: " + pos_x*local2world, 10, 65);
  text("Position y: " + pos_y*local2world, 10, 80);
  
  text("'wasd' (or arrow keys) to move\n'space' to light up surroundings\n'.' to reset world", 215, 20);
}

void renderGrid()
{
  // Render grid
  stroke(100);
  for (int i = 0; i < g_width; i++) {
    line((i - pos_x)*local2world, (0 - pos_y)*local2world, (i - pos_x)*local2world, (g_height - pos_y)*local2world);
  }
  for (int j = 0; j < g_height; j++) {
    line((0 - pos_x)*local2world, (j - pos_y)*local2world, (g_width - pos_x)*local2world, (j - pos_y)*local2world);
  }
  line((0 - pos_x)*local2world, (g_height - pos_y)*local2world, (g_width - pos_x)*local2world, (g_height - pos_y)*local2world);
  line((g_width - pos_x)*local2world, (0 - pos_y)*local2world, (g_width - pos_x)*local2world, (g_height - pos_y)*local2world);
}

void debug()
{
  // Debug view
  renderGrid();
  renderCollision();
  renderLight();  
  renderShadow();
  renderAgentShadow();
  renderCompanionInfo();
  renderInfo();
}
