void initControl()
{  
  // Initialize keys and controls
  for (int i = 0; i < 4; i++) keys[i] = false;
}

void updateControls()
{
  walking = false;
  if (keys[w]) { // Up
    direction = 0;
    processCollision(agentAABB); // Check collision
    if (!agentAABB.collision[w]) { vel_y = -2.0; walking = true; }
  }
  if (keys[a]) { // Left
    direction = 1;
    processCollision(agentAABB); // Check collision 
    if (!agentAABB.collision[a]) { vel_x = -2.0; walking = true; }
  }
  if (keys[s]) { // Down
    direction = 2;
    processCollision(agentAABB); // Check collision
    if (!agentAABB.collision[s]) { vel_y = 2.0; walking = true; }
  }
  if (keys[d]) { // Right
    direction = 3;
    processCollision(agentAABB); // Check collision
    if (!agentAABB.collision[d]) { vel_x = 2.0; walking = true; }
  }
}

void keyPressed() {
  if (ending == 0) {
         if (key == 'w' || (key == CODED && keyCode == UP)) keys[w] = true;
    else if (key == 'a' || (key == CODED && keyCode == LEFT)) keys[a] = true;
    else if (key == 's' || (key == CODED && keyCode == DOWN)) keys[s] = true;
    else if (key == 'd' || (key == CODED && keyCode == RIGHT)) keys[d] = true;
  
    if (key == ' ' && !finale) flash = !flash;
    if (key == ',') { lightsources.clear(); ending = 1; }
    if (key == '.') { step.pause(); initLighters(); }
    
    if (key == CODED) {
      if (keyCode == SHIFT) debugview = !debugview;
    }
  }
  else if (ending == 7) {
    if (key == ' ' || key == '.') {
      song.pause();
      ending = 0;
      initLighters();
    }
  }
}

void keyReleased() {
  if (ending == 0) {
         if (key == 'w' || (key == CODED && keyCode == UP)) keys[w] = false;
    else if (key == 'a' || (key == CODED && keyCode == LEFT)) keys[a] = false;
    else if (key == 's' || (key == CODED && keyCode == DOWN)) keys[s] = false;
    else if (key == 'd' || (key == CODED && keyCode == RIGHT)) keys[d] = false;
  }
}
