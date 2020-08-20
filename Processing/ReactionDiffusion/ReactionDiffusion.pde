/********************************************************

Author:  Dale Thomas
Date:    2020/08/20
Website: chaoticedgegames.com

 ********************************************************/

float[][][][] dish;
int back_buffer = 0;

float DIFFUSION_A = 0.9;
float DIFFUSION_B = 0.2;
float REACTION_SPEED = 0.2;

float F = 0.05;
float K = 0.07;

void clearDish()
{
  back_buffer = 0;
  for (int y=0; y<height; y++)
  {
    for (int x=0; x<width; x++)
    {
      dish[back_buffer][x][y][0] = random(1.0);
      dish[back_buffer][x][y][1] = random(1.0);
    }
  }
}

void updateDish()
{
  int front_buffer = back_buffer ^ 1;
  for (int y=0; y<height; y++)
  {
    float fy = y / (height-1.0);
    for (int x=0; x<width; x++)
    {
      float fx = x / (height-1.0);

      float old_a = dish[back_buffer][x][y][0];
      float old_b = dish[back_buffer][x][y][1];

      float laplace_a = 0.0;
      laplace_a += (x>0) ? dish[back_buffer][x-1][y][0] : old_a;
      laplace_a += (x<width-1) ? dish[back_buffer][x+1][y][0] : old_a;
      laplace_a += (y>0) ? dish[back_buffer][x][y-1][0] : old_a;
      laplace_a += (y<height-1) ? dish[back_buffer][x][y+1][0] : old_a;
      laplace_a *= 0.25;

      float laplace_b = 0.0;
      laplace_b += (x>0) ? dish[back_buffer][x-1][y][1] : old_b;
      laplace_b += (x<width-1) ? dish[back_buffer][x+1][y][1] : old_b;
      laplace_b += (y>0) ? dish[back_buffer][x][y-1][1] : old_b;
      laplace_b += (y<height-1) ? dish[back_buffer][x][y+1][1] : old_b;
      laplace_b *= 0.25;

      float new_a = old_a;
      float new_b = old_b;

      // *** reaction ***
      float abb = old_a * old_b * old_b;
      new_a += REACTION_SPEED * ( F * (1.0 - old_a) - abb );
      new_b += REACTION_SPEED * ( abb - (F+K) * old_b );

      // *** diffusion ***
      new_a += (laplace_a-old_a) * DIFFUSION_A;
      new_b += (laplace_b-old_b) * DIFFUSION_B;

      dish[front_buffer][x][y][0] = new_a;
      dish[front_buffer][x][y][1] = new_b;
    }
  }

  back_buffer = front_buffer;
}

void mouseDragged()
{
  int r = 5;  
  int xmin = max(mouseX-r, 0);
  int xmax = min(mouseX+r, width-1);
  int ymin = max(mouseY-r, 0);
  int ymax = min(mouseY+r, height-1);
  
  for (int y=ymin; y<=ymax; y++)
  {
    for (int x=xmin; x<=xmax; x++)
    {
      dish[back_buffer][x][y][0] = 0.0;
      dish[back_buffer][x][y][1] = 1.0;
    }
  }
}

void setup()
{
  size(256, 256);

  dish = new float[2][width][height][2];

  clearDish();
}

void draw()
{
      F = 0.1 * (mouseX / (width-1.0));
      K = 0.1 * (mouseY / (height-1.0));

  
  for (int i=0; i<10; i++) updateDish();

  loadPixels();
  for (int y=0; y<height; y++)
  {
    for (int x=0; x<width; x++)
    {
      pixels[x+y*width] = color(int(dish[back_buffer][x][y][0]*255), int(dish[back_buffer][x][y][1]*255), 0);
    }
  }
  updatePixels();
}
