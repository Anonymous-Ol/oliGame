# importing the modules
import cv2
import numpy as np
from tkinter import Tk     # from tkinter import Tk for Python 3.x
from tkinter.filedialog import askopenfilename, asksaveasfile

Tk().withdraw()

# read all the images
# we are going to take 4 images only
image1=cv2.imread(askopenfilename())
image2=cv2.imread(askopenfilename())
image3=cv2.imread(askopenfilename())
image4=cv2.imread(askopenfilename())
image5=cv2.imread(askopenfilename())
image6=cv2.imread(askopenfilename())
# make all the images of same size 
#so we will use resize function
image1=cv2.resize(image1,(2048,2048))
image2=cv2.resize(image2,(2048,2048))
image3=cv2.resize(image3,(2048,2048))
image4=cv2.resize(image4,(2048,2048))
image5=cv2.resize(image5,(2048,2048))
image6=cv2.resize(image6,(2048,2048))


Vertical_attachment = np.vstack([image1,image2,image3,image4,image5,image6])
# Show the final attachment
cv2.imwrite("cubeMapVertical.png", Vertical_attachment)
cv2.imshow("Final Collage",Vertical_attachment)
cv2.waitKey(0)
cv2.destroyAllWindows()

