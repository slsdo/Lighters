void initSound()
{
  minim = new Minim(this); 
  song = minim.loadFile("lighters.wav");
}
