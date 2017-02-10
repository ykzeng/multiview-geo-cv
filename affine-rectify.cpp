#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/opencv.hpp>

#include<iostream>
#include<conio.h>           // may have to modify this line if not using Windows

using namespace std;
using namespace cv;

int main() {
  Mat imgOriginal, imgOut, myOut;        // input image, output image after findHomo, my output

  imgOriginal = imread("pics\\hw1-1.jpg");          // open image
  myOut = imgOriginal.clone();

  double pt1_arr[] = {1271, 546, 1},
    pt2_arr[] = {1276, 936, 1}, 
    pt3_arr[] = {1626, 537, 1},
    pt4_arr[] = {1619, 877, 1};
  CvMat pt1 = cvMat(1, 3, CV_64FC1, pt1_arr),
    pt2 = cvMat(1, 3, CV_64FC1, pt2_arr),
    pt3 = cvMat(1, 3, CV_64FC1, pt3_arr),
    pt4 = cvMat(1, 3, CV_64FC1, pt4_arr);

  //defining parallel lines
  CvMat *l1 = cvCreateMat(1, 3, CV_64FC1), 
    *l2 = cvCreateMat(1, 3, CV_64FC1), 
    *m1 = cvCreateMat(1, 3, CV_64FC1), 
    *m2 = cvCreateMat(1, 3, CV_64FC1);

  //defining infinite points and inf line
  CvMat *v1 = cvCreateMat(1, 3, CV_64FC1), 
    *v2 = cvCreateMat(1, 3, CV_64FC1),
    *vanishLine = cvCreateMat(1, 3, CV_64FC1);

  //calculating parallel line
  cout << "(" << CV_MAT_ELEM(pt1, double, 0, 0) 
    << ", " << CV_MAT_ELEM(pt1, double, 0, 1) << ")" << endl;
  cout << "(" << CV_MAT_ELEM(pt2, double, 0, 0)
    << ", " << CV_MAT_ELEM(pt2, double, 0, 1) << ")" << endl;
  cvCrossProduct(&pt1, &pt2, l1);
  cout << "(" << CV_MAT_ELEM(*l1, double, 0, 0)
    << ", " << CV_MAT_ELEM(*l1, double, 0, 1) 
    << ", " << CV_MAT_ELEM(*l1, double, 0, 2) << ")" << endl;
  cvCrossProduct(&pt3, &pt4, l2);
  cvCrossProduct(&pt1, &pt3, m1);
  cvCrossProduct(&pt2, &pt4, m2);

  //calculating vanish line
  cvCrossProduct(l1, l2, v1);
  cvCrossProduct(m1, m2, v2);
  cvCrossProduct(v1, v2, vanishLine);

  CvMat *homo = cvCreateMat(3, 3, CV_64FC1);
  cvSetZero(homo);
  cvmSet(homo, 0, 0, 1);
  cvmSet(homo, 1, 1, 1);
  cvmSet(homo, 2, 0, cvmGet(vanishLine, 0, 0));
  cvmSet(homo, 2, 1, cvmGet(vanishLine, 0, 1));
  cvmSet(homo, 2, 2, cvmGet(vanishLine, 0, 2));

  cv::warpPerspective(imgOriginal, myOut, cvarrToMat(homo), imgOriginal.size());

  cv::imshow("MyAffineTransform", myOut);

  waitKey(0);
}