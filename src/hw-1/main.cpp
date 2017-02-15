#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/opencv.hpp>
#include"rectifyToAffinity.h"

#include<iostream>
#include<conio.h>           // may have to modify this line if not using Windows

using namespace cv;
using namespace std;

int main() {
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
                        1619, 877, 1};
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