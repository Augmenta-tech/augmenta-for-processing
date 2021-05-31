// 3D functions

void createEasyCam(){
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(800); 
}

void manage3DMatrix(){
 // Check if the matrix is the identity or not
  float[] m = new float[16];
  getMatrix().get(m);
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      if ((i == j && m[i*4+j] == 1) || (i !=j && m[i*4+j] == 0)){
        canvas.setMatrix(lastCamMatrix);
      } else {
        lastCamMatrix = getMatrix();
        canvas.setMatrix(getMatrix()); // replace the PGraphics-matrix
      }
    }
  } 
}

void updateMatrix() {
  
    if(updateOriginalMatrix == true){
   // The scene has been resized, save the new original matrix and recreate the easycam
   originalMatrix = getMatrix();
   setMatrix(originalMatrix);
   createEasyCam();
   updateOriginalMatrix = false;
  } else{ 
    setMatrix(originalMatrix); // replace the PeasyCam-matrix
  }

}
