#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/opencv.hpp>
#include"rectifyToAffinity.h"
#include"calibration.h"
#include<iostream>
#include<conio.h>           // may have to modify this line if not using Windows

using namespace cv;
using namespace std;

vector<Point2f> Generate2DPoints() {


  /*double imgX[] = { 176,   139,
    227,   466,
    434,   236,
    313, 324 };*/

  vector<Point2f>points;
  float x, y;

  x = 176; y = 139;
  points.push_back(Point2f(x, y));

  x = 227; y = 466;
  points.push_back(Point2f(x, y));

  x = 434; y = 236;
  points.push_back(Point2f(x, y));

  x = 313; y = 324;
  points.push_back(Point2f(x, y));

  return points;
}

vector<Point3f> Generate3DPoints() {

  /*double worldX[] = { 0, 270, 0,
    30, 60, 0,
    180, 210, 0,
    90, 150, 0 };*/

  vector<Point3f>points;
  float x, y, z;

  x = 0; y = 270; z = 0;
  points.push_back(Point3f(x, y, z));

  x = 30; y = 60; z = 0;
  points.push_back(Point3f(x, y, z));

  x = 180; y = 210; z = 0;
  points.push_back(Point3f(x, y, z));

  x = 90; y = 150; z = 0;
  points.push_back(Point3f(x, y, z));

  return points;
}

void camCalibrate() {
  Mat imgOriginal;        // input image, output image after findHomo, my output
  imgOriginal = imread("pics\\p3p.jpg");          // open image
  //Mat cameraMat = Mat(3, 4, CV_64FC1), distortionCoe = Mat(1, 4, CV_64FC1);
  //CalibrateOpenCV(imgOriginal, cameraMat, distortionCoe);
  
  Mat cameraMatrix(3, 3, DataType<double>::type);
  setIdentity(cameraMatrix);

  vector<Point3f> world = Generate3DPoints();
  vector<Point2f> img = Generate2DPoints();
  // initialize fx fy cx cy
  cameraMatrix.at<double>(0, 0) = 438.7795938256493;
  cameraMatrix.at<double>(1, 1) = 428.3166621327036;
  cameraMatrix.at<double>(0, 2) = 156.4369276062062;
  cameraMatrix.at<double>(1, 2) = 319.7357482216087;

  // L(r) coefficients
  Mat distCoeffs(4, 1, DataType<double>::type);
  distCoeffs.at<double>(0) = 0;
  distCoeffs.at<double>(1) = 0;
  distCoeffs.at<double>(2) = 0;
  distCoeffs.at<double>(3) = 0;

  Mat rvec(3, 1, DataType<double>::type);
  Mat tvec(3, 1, DataType<double>::type);
  Mat rotM(3, 3, DataType<double>::type);
  solvePnP(world, img, cameraMatrix, distCoeffs, rvec, tvec, false, CV_EPNP);
  Rodrigues(rvec, rotM);
  cout << "Rotation mat" << rotM << endl;
  cout << "Translation vec" << tvec << endl;
}

void fourPtRectify() {
  Mat imgOriginal, affinityOut, normalOut, fourPOut, standardOut;        // input image, output image after findHomo, my output

  imgOriginal = imread("pics\\hw1-1.jpg");          // open image
  affinityOut = imgOriginal.clone();
  normalOut = imgOriginal.clone();
  fourPOut = imgOriginal.clone();
  standardOut = imgOriginal.clone();

  /*double pt1_arr[] = { 1271, 546, 1 },
  pt2_arr[] = { 1276, 936, 1 },
  pt3_arr[] = { 1626, 537, 1 },
  pt4_arr[] = { 1619, 877, 1 };*/
  double pts_data[] = { 1271, 546, 1,
    1276, 936, 1,
    1626, 537, 1,
    1619, 877, 1 };
  CvMat *pts = &(cvMat(4, 3, CV_64FC1, pts_data));

  double sqr_pts_data[] = { 1793, 1697, 1,
    1878, 1647, 1,
    1924, 1747, 1,
    2006, 1692, 1 };
  CvMat *sqr_pts = &(cvMat(4, 3, CV_64FC1, sqr_pts_data));

  fourPointRectify(imgOriginal, standardOut, fourPOut);
  cv::imwrite(".\\standard-normal.jpeg", standardOut);
  cv::imwrite(".\\four-point-normal.jpeg", fourPOut);
  /*CvMat pt1 = cvMat(1, 3, CV_64FC1, pt1_arr),
  pt2 = cvMat(1, 3, CV_64FC1, pt2_arr),
  pt3 = cvMat(1, 3, CV_64FC1, pt3_arr),
  pt4 = cvMat(1, 3, CV_64FC1, pt4_arr);*/
  // define the homo from picture space to affinity
  CvMat *H_A = cvCreateMat(3, 3, CV_64FC1);
  cvSetZero(H_A);
  rectifyToAffinity(imgOriginal, pts, H_A, affinityOut);
  affinityToNormal(imgOriginal, pts, H_A, normalOut);
  /*rectifyToAffinity(imgOriginal, sqr_pts, H_A, affinityOut);
  affinityToNormal(imgOriginal, sqr_pts, H_A, normalOut);*/
  waitKey(0);
}

int main() {
  //fourPtRectify();
  camCalibrate();
  system("PAUSE");
}