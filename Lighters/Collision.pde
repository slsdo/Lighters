void initCollision()
{
  blocks = new ArrayList<AABB>(); // Initialize boundary blocks
  
  // Find edge wall grid cells and generate collision bodies for them
  for (int j = 0; j < g_height; j++) {
    for (int i = 0; i < g_width; i++) {
      if (grid[i + j*g_width] == 0 && (!wall(i + 1, j) || !wall(i - 1, j) || !wall(i, j + 1) || !wall(i, j - 1))) {
        blocks.add(new AABB((i - pos_x)*local2world, (j - pos_y )*local2world, local2world, local2world, i, j));
      }
    }
  }
}

void processCollision(AABB b)
{
  for (int i = 0; i < 4; i++) b.collision[i] = false; // Reset collision
  
  // Go through all boundary blocks
  for (AABB wall: blocks) {
    if (collideRectRect(b, wall)) {
      wall.colliding = true; // For debuging purposes
      
      // Get vector from agent to colliding wall
      PVector cvec = new PVector(wall.c.x, wall.c.y);
      cvec.sub(b.c);

      if (abs(cvec.x) >= abs(cvec.y)) { // If collision is on left or right side
        if (cvec.x > 0 && wall(index_x + 1, index_y)) b.collision[d] = true; // If left and there is wall
        if (cvec.x < 0 && wall(index_x - 1, index_y)) b.collision[a] = true; // If right and there is wall
      }
      else { // If collision is on upper or lower side
        if (cvec.y > 0 && wall(index_x, index_y + 1)) b.collision[s] = true; // If down and there is wall
        if (cvec.y < 0 && wall(index_x, index_y - 1)) b.collision[w] = true; // If up and there is wall
      }
    }
    else {
      wall.colliding = false; // No collision
    }
  }
}

boolean collideRectRect(AABB b1, AABB b2)
{
  // Check if the boxes overlap
  return !(b1.x > (b2.x + b2.w) || (b1.x + b1.w) < b2.x || b1.y > (b2.y + b2.h) || (b1.y + b1.h) < b2.y);
}

boolean bounded(int x, int y)
{
  // Check if cell is inside grid
  if (x < 0 || x >= g_width || y < 0 || y >= g_height) return false;
  return true;
}

boolean blocked(int x, int y)
{
  // Check if cell is occupied
  if (bounded(x, y) && grid[x + y*g_width] != 1) return true;
  return false;
}

boolean wall(int x, int y)
{
  // Check if cell is occupied by wall
  if (!bounded(x, y) || grid[x + y*g_width] == 0) return true;
  return false;
}

void renderCollision()
{
  for (AABB wall: blocks) wall.render(); // Render wall bounding box
  agentAABB.render(); // Render the manager's bounding box ;)
}

class AABB {
  int idx; // Index x
  int idy; // Index y
  float x; // Position x world coordinate
  float y; // Position y world coordinate
  float w; // Width world coordinate
  float h; // Height world coordinate
  PVector c; // Center position world coordinate
  boolean colliding = false; // If body is colliding
  boolean[] collision; // Collision direction
  PVector pt1;
  PVector pt2;
  PVector pt3;
  PVector pt4;

  AABB(float aabb_x,float aabb_y, float aabb_w, float aabb_h, int id_x, int id_y)
  {
    idx = id_x;
    idy = id_y;
    x = aabb_x;
    y = aabb_y;
    w = aabb_w;
    h = aabb_h;
    c = new PVector((x + w*0.5), (y + h*0.5));
    collision = new boolean[4];
    for (int i = 0; i < 4; i++) collision[i] = false;
    
    pt1 = new PVector(x, y);
    pt2 = new PVector(x + w, y);
    pt3 = new PVector(x + w, y + h);
    pt4 = new PVector(x, y + h);
  }
  
  void update(float aabb_x, float aabb_y)
  {
    x = aabb_x;
    y = aabb_y;
    c.x = x + w*0.5;
    c.y = y + h*0.5;
    
    pt1 = new PVector(x, y);
    pt2 = new PVector(x + w, y);
    pt3 = new PVector(x + w, y + h);
    pt4 = new PVector(x, y + h);
  }
  
  void render()
  {
    // Color if colliding
    if (colliding) stroke (204, 102, 0);
    else stroke(0, 102, 153);
    noFill();
    rect(x, y, w, h);
  }  
}
