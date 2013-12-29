void initTileMap()
{
  tilemap_sprite = loadImage("sprite_tilemap.png");
  cacheTileMap(); // Generate image of map from grid
  tilemap = createImage(g_width*t_size, g_height*t_size, RGB); // Initialize tilemap for later use
  
  dusk(60); // Add darkness
}

void dusk(int darkness)
{
  // Add darkness to tilemap cache
  tilemapcache.loadPixels();
  for (int j = 0; j < tilemapcache.height; j++ ) {
    for (int i = 0; i < tilemapcache.width; i++) {
      int p_index = i + j*tilemapcache.width;
      color original = color(tilemapcache.pixels[p_index]); // Get original tilemap
      color dark = color(darkness, darkness, darkness); // Darkness
      color result = blendColor(original, dark, SUBTRACT); // Originally not lighted
      
      // Constrain RGB to make sure they are within 0-255 color range
      float r = red(result); float g = green(result); float b = blue(result);
      constrain(r, 0, 255); constrain(g, 0, 255); constrain(b, 0, 255);
      result = color(r, g, b);
      tilemapcache.pixels[p_index] = result;
    }
  }
  tilemapcache.updatePixels(); 
}

void cacheTileMap()
{
  tilemap_sprite.loadPixels();  
  tilemapcache = createImage(g_width*t_size, g_height*t_size, RGB);
  tilemapcache.loadPixels();
  
  // Take tiles from tilemap and create a new image based on values stored in the grid
  for (int j = 0; j < g_height*t_size; j++) {
    for (int i = 0; i < g_width*t_size; i++) {
      int x = i/t_size; // Get grid index x
      int y = j/t_size; // Get grid index y
      switch (grid[x + y*g_width]) {
        case 0: // Wall
        {
               if (!wall(x, y - 1) && !wall(x + 1, y) && !wall(x, y + 1) && !wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 0*t_size) + ((j%t_size) + 1*t_size)*(t_size*5)]; }
          else if ( wall(x, y - 1) && !wall(x + 1, y) && !wall(x, y + 1) && !wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 1*t_size) + ((j%t_size) + 1*t_size)*(t_size*5)]; }
          else if (!wall(x, y - 1) && !wall(x + 1, y) &&  wall(x, y + 1) && !wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 2*t_size) + ((j%t_size) + 1*t_size)*(t_size*5)]; }
          else if ( wall(x, y - 1) && !wall(x + 1, y) &&  wall(x, y + 1) && !wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 3*t_size) + ((j%t_size) + 1*t_size)*(t_size*5)]; }
          else if (!wall(x, y - 1) &&  wall(x + 1, y) && !wall(x, y + 1) && !wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 4*t_size) + ((j%t_size) + 1*t_size)*(t_size*5)]; }
          else if ( wall(x, y - 1) &&  wall(x + 1, y) && !wall(x, y + 1) && !wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 0*t_size) + ((j%t_size) + 2*t_size)*(t_size*5)]; }
          else if (!wall(x, y - 1) &&  wall(x + 1, y) &&  wall(x, y + 1) && !wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 1*t_size) + ((j%t_size) + 2*t_size)*(t_size*5)]; }
          else if ( wall(x, y - 1) &&  wall(x + 1, y) &&  wall(x, y + 1) && !wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 2*t_size) + ((j%t_size) + 2*t_size)*(t_size*5)]; }
          else if (!wall(x, y - 1) && !wall(x + 1, y) && !wall(x, y + 1) &&  wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 3*t_size) + ((j%t_size) + 2*t_size)*(t_size*5)]; }
          else if ( wall(x, y - 1) && !wall(x + 1, y) && !wall(x, y + 1) &&  wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 4*t_size) + ((j%t_size) + 2*t_size)*(t_size*5)]; }
          else if (!wall(x, y - 1) && !wall(x + 1, y) &&  wall(x, y + 1) &&  wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 0*t_size) + ((j%t_size) + 3*t_size)*(t_size*5)]; }
          else if ( wall(x, y - 1) && !wall(x + 1, y) &&  wall(x, y + 1) &&  wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 1*t_size) + ((j%t_size) + 3*t_size)*(t_size*5)]; }
          else if (!wall(x, y - 1) &&  wall(x + 1, y) && !wall(x, y + 1) &&  wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 2*t_size) + ((j%t_size) + 3*t_size)*(t_size*5)]; }
          else if ( wall(x, y - 1) &&  wall(x + 1, y) && !wall(x, y + 1) &&  wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 3*t_size) + ((j%t_size) + 3*t_size)*(t_size*5)]; }
          else if (!wall(x, y - 1) &&  wall(x + 1, y) &&  wall(x, y + 1) &&  wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 4*t_size) + ((j%t_size) + 3*t_size)*(t_size*5)]; }
          else if ( wall(x, y - 1) &&  wall(x + 1, y) &&  wall(x, y + 1) &&  wall(x - 1, y )) { tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 0*t_size) + ((j%t_size) + 4*t_size)*(t_size*5)]; }
          if (!wall(x - 1, y + 1)) { if (tilemap_sprite.pixels[(i%t_size + 1*t_size) + ((j%t_size) + 4*t_size)*(t_size*5)] != -65281) tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 1*t_size) + ((j%t_size) + 4*t_size)*(t_size*5)]; }
          if (!wall(x - 1, y - 1)) { if (tilemap_sprite.pixels[(i%t_size + 2*t_size) + ((j%t_size) + 4*t_size)*(t_size*5)] != -65281) tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 2*t_size) + ((j%t_size) + 4*t_size)*(t_size*5)]; }
          if (!wall(x + 1, y - 1)) { if (tilemap_sprite.pixels[(i%t_size + 3*t_size) + ((j%t_size) + 4*t_size)*(t_size*5)] != -65281) tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 3*t_size) + ((j%t_size) + 4*t_size)*(t_size*5)]; }
          if (!wall(x + 1, y + 1)) { if (tilemap_sprite.pixels[(i%t_size + 4*t_size) + ((j%t_size) + 4*t_size)*(t_size*5)] != -65281) tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 4*t_size) + ((j%t_size) + 4*t_size)*(t_size*5)]; }
          break;
        }
        case 1: 
        case 2: 
        case 3: 
        case 4: // Floor
        {
          switch (tiles[x + y*g_width]) {
            case 0: tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 0*t_size) + (j%t_size)*(t_size*5)]; break;
            case 1: tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 1*t_size) + (j%t_size)*(t_size*5)]; break;
            case 2: tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 2*t_size) + (j%t_size)*(t_size*5)]; break;
            case 3: tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 3*t_size) + (j%t_size)*(t_size*5)]; break;
            case 4: tilemapcache.pixels[i + j*g_width*t_size] = tilemap_sprite.pixels[(i%t_size + 4*t_size) + (j%t_size)*(t_size*5)]; break;
          }
          break;
        }
      }
    }
  }
  
  tilemapcache.updatePixels();  
}

void renderTileMap()
{
  // Render cached tilemap with light and shadow
  image(tilemap, (0 - pos_x)*local2world, (0 - pos_y)*local2world, g_width*local2world, g_height*local2world);
}

void renderTileMapCache()
{
  // Render cached tilemap
  image(tilemapcache, (0 - pos_x)*local2world, (0 - pos_y)*local2world, g_width*local2world, g_height*local2world);
}
