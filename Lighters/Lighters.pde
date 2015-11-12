/* Lighters
   http://www.futuredatalab.com/lighters/
   
   Compatible with Processing 2.2.1
*/

import java.util.Collections;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

// World
boolean debugview = false;
byte[] grid; // Grid array
final int g_width = 20; // Grid width
final int g_height = 15; // Grid height5
float pos_x = 0; // Current x position
float pos_y = 0; // Current y position
float vel_x = 0; // Current x velocity
float vel_y = 0; // Current y velocity
int index_x = 0; // Current agent x index
int index_y = 0; // Current agent y index
PCG pcg; // Procedural content generation grid
final int s_size = 3; // Scale size
final int t_size = 16; // Tile size
final int local2world = s_size*t_size;
final float world2local = 1.0/local2world;
final int frame_count = 16; // Walking animation framecount

// Control
boolean[] keys = new boolean[4]; // Check key press
final int w = 0; // Up
final int a = 2; // Left
final int s = 1; // Down
final int d = 3; // Right
int direction = 1; // For walking animation

// Sprites
PImage agent_sprite;
PImage candle_sprite;
PImage companion_sprite;
PImage tilemap_sprite;
PImage end_sprite;
PImage stars_sprite;
PImage tilemap;
PImage tilemapcache;
PImage walk[];
PImage flicker[];
PImage shine[];
PImage bng[];
byte[] tiles; // Random floor tiles

// Collision
ArrayList<AABB> blocks; // Bounding blocks
AABB agentAABB; // Agent

// Light
final int light_num = 5; // Number of light sources
final float lightsrc_rad = 3.0; // Light source radius
final float lightc_rad = 1.5; // Agent light radius
ArrayList<LightMap> lightsources; // Light source locations
LightCompanion lc; // Light companion
boolean flash = false; // Light up this world!

// Sound
Minim minim;
AudioPlayer step;
boolean walking = false; // Walking or not

// End
boolean finale = false;
AudioPlayer song;
int ending = 0;
int count = 0;
int star_num = 70;
int meteo_num = 30;
boolean starrynight = false;
PVector[] stars = new PVector[star_num];
boolean makeawish = false;
PVector[] meteor = new PVector[meteo_num];
PVector start;
float msize;
PVector delta;
int timer = -1;

void setup() {
  if (!online) {
    frame.setTitle("Lighters");
    PImage icon = loadImage("icon.png");
    frame.setIconImage(icon.getImage());
  }
  size(400, 300);
  noSmooth();
  initLighters();
}

void draw() {
  if (ending == 0) updateLighters();
  else endLighters();
}

void initLighters()
{
  initWorld(); // Initialize the world
  initSound(); // Initialize sounds
  initControl(); // Initialize controls
  initAgent(); // Initialize manager ;)
  initCompanion(); // Initialize light companion
  initCollision(); // Initialize collision bodies
  initLightSource(); // Initialize light emitting objects
  initTileMap(); // Initialize tilemap
  initEnd();
}

void updateLighters()
{
  updateWorld(); // Update parameters
  updateControls(); // Check for action
  updateLightSource(); // Generate light from light sources
  updateLightCompanion(); // Generate light from light companion

  background(0);
  renderTileMap();
  renderLightSource();
  renderAgent();
  renderLightCompanion();
  if (debugview) debug();
}

