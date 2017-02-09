#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/opencv.hpp>

#include<iostream>
#include<conio.h>           // may have to modify this line if not using Windows

using namespace cv;
using namespace std;

int main() {
  Mat imgOriginal, imgOut, myOut;        // input image

  imgOriginal = imread("pics\\hw1-1.jpg");          // open image
  imgOut = imgOriginal.clone();
  myOut = imgOriginal.clone();

  if (imgOriginal.empty()) {                                  // if unable to open image
    std::cout << "error: image not read from file\n\n";     // show error message on command line
    _getch();                                               // may have to modify this line if not using Windows
    return(0);                                              // and exit program
  }
  
  int xy[4][2] = { {1271, 546},
  {1626, 537},
  {1276, 936},
  {1619, 877} };

  int _xy[4][2] = { { 1271, 546 },
  { 1626, 546 },
  { 1271, 877 },
  { 1626, 877 } };

  vector<Point2f> pts_src, pts_dest;
  pts_src.push_back(Point2f(1271, 546));
  pts_src.push_back(Point2f(1626, 537));
  pts_src.push_back(Point2f(1276, 936));
  pts_src.push_back(Point2f(1619, 877));

  pts_dest.push_back(Point2f(1271, 546));
  pts_dest.push_back(Point2f(1626, 546));
  pts_dest.push_back(Point2f(1271, 877));
  pts_dest.push_back(Point2f(1626, 877));

  Mat homography = findHomography(pts_src, pts_dest);

  cv::warpPerspective(imgOriginal, imgOut, homography, imgOriginal.size());

  cv::imshow("Original", imgOriginal);
  cv::imshow("Rectified", imgOut);

  CvMat *p_mat = cvCreateMat(8, 8, CV_64FC1), 
    *h_vec = cvCreateMat(8, 1, CV_64FC1), 
    *xy_mat = cvCreateMat(8, 1, CV_64FC1);
  
  cvSetZero(p_mat);
  cvSetZero(h_vec);
  cvSetZero(xy_mat);
  
  for (int i = 0; i < 4; i++)
  {
    //pi
    //col0: x
    cvmSet(p_mat, (i * 2), 0, xy[i][0]);
    //col1: y
    cvmSet(p_mat, (i * 2), 1, xy[i][1]);
    //col2: 1
    cvmSet(p_mat, (i * 2), 2, 1);
    //col3-5: 0
    //col6: -_xx
    int _xx = xy[i][0] * _xy[i][0];
    cvmSet(p_mat, (i * 2), 6, -_xx);
    //col7: -_xy
    int y_x = xy[i][1] * _xy[i][0];
    cvmSet(p_mat, (i * 2), 7, -y_x);

    //_pi
    //col0-2: 0
    //col3: xi
    cvmSet(p_mat, (i * 2 + 1), 3, xy[i][0]);
    //col4: yi
    cvmSet(p_mat, (i * 2 + 1), 4, xy[i][1]);
    //col5: 1
    cvmSet(p_mat, (i * 2 + 1), 5, 1);
    //col6: -xi_yi
    int x_y = xy[i][0] * _xy[i][1];
    cvmSet(p_mat, (i * 2 + 1), 6, -x_y);
    //col7: -yi_yi
    int y_y = xy[i][1] * _xy[i][1];
    cvmSet(p_mat, (i * 2 + 1), 7, -y_y);

    //one col mat consists of _x and _y
    cvmSet(xy_mat, (i * 2), 0, _xy[i][0]);
    cvmSet(xy_mat, (i * 2 + 1), 0, _xy[i][1]);
  }
  //p_mat.
  //solve()
  cvSolve(p_mat, xy_mat, h_vec);

  CvMat *my_cv_homo = cvCreateMat(3, 3, CV_64FC1);

  for (int i = 0; i < 8; i++)
  {
    int row = i / 3, col = i % 3;
    cvmSet(my_cv_homo, row, col, cvmGet(h_vec, i, 0));
  }
  cvmSet(my_cv_homo, 2, 2, 1);

  Mat my_homo = cvarrToMat(my_cv_homo);

  cv::warpPerspective(imgOriginal, myOut, my_homo, imgOriginal.size());

  cv::imshow("MyTransform", myOut);

  waitKey(0);

}