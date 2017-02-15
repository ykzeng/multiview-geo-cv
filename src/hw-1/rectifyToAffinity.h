#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/opencv.hpp>

#include<iostream>
#include<conio.h>           // may have to modify this line if not using Windows

using namespace std;
using namespace cv;

// this is the first draft version, change the name to main to get a total recovery of my first
// affinity rectification version
void test() {
  Mat imgOriginal, imgOut, myOut;        // input image, output image after findHomo, my output

  imgOriginal = imread("pics\\hw1-1.jpg");          // open image
  myOut = imgOriginal.clone();

  double pt1_arr[] = { 1271, 546, 1 },
    pt2_arr[] = { 1276, 936, 1 },
    pt3_arr[] = { 1626, 537, 1 },
    pt4_arr[] = { 1619, 877, 1 };
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
  /*cout << "The two upper rectangle apexes:" << endl;
  cout << "(" << CV_MAT_ELEM(pt1, double, 0, 0)
  << ", " << CV_MAT_ELEM(pt1, double, 0, 1) << ")" << endl;
  cout << "(" << CV_MAT_ELEM(pt2, double, 0, 0)
  << ", " << CV_MAT_ELEM(pt2, double, 0, 1) << ")" << endl;*/
  cvCrossProduct(&pt1, &pt2, l1);
  /*cout << "The first parallel line: " << endl;
  cout << "(" << CV_MAT_ELEM(*l1, double, 0, 0)
  << ", " << CV_MAT_ELEM(*l1, double, 0, 1)
  << ", " << CV_MAT_ELEM(*l1, double, 0, 2) << ")" << endl;*/
  cvCrossProduct(&pt3, &pt4, l2);
  cvCrossProduct(&pt1, &pt3, m1);
  cvCrossProduct(&pt2, &pt4, m2);

  //calculating vanish line
  cvCrossProduct(l1, l2, v1);
  cvCrossProduct(m1, m2, v2);
  cvCrossProduct(v1, v2, vanishLine);

  // idea from https://engineering.purdue.edu/kak/computervision/ECE661.08/solution/hw2_s2.pdf
  // normalize vanishing line
  // in order to map the distorted image back to the image window
  double scale = 3.0;
  cvmSet(vanishLine, 0, 0, cvmGet(vanishLine, 0, 0) / cvmGet(vanishLine, 0, 2)*scale);
  cvmSet(vanishLine, 0, 1, cvmGet(vanishLine, 0, 1) / cvmGet(vanishLine, 0, 2)*scale);
  cvmSet(vanishLine, 0, 2, 1.0*scale);

  /*cout << "The vanishing line:" << endl;
  cout << "(" << CV_MAT_ELEM(*vanishLine, double, 0, 0)
  << ", " << CV_MAT_ELEM(*vanishLine, double, 0, 1)
  << ", " << CV_MAT_ELEM(*vanishLine, double, 0, 2) << ")" << endl;*/

  CvMat *homo = cvCreateMat(3, 3, CV_64FC1);
  cvSetZero(homo);
  cvmSet(homo, 0, 0, 1);
  cvmSet(homo, 1, 1, 1);
  cvmSet(homo, 2, 0, cvmGet(vanishLine, 0, 0));
  cvmSet(homo, 2, 1, cvmGet(vanishLine, 0, 1));
  cvmSet(homo, 2, 2, cvmGet(vanishLine, 0, 2));

  cv::warpPerspective(imgOriginal, myOut, cvarrToMat(homo), imgOriginal.size());
  cv::imwrite(".\\test.jpeg", myOut);
  //cv::imshow("MyAffineTransform", myOut);

  waitKey(0);
}


//============================================================================================================================
// @param imgOriginal the original img for rectification
// @param H_A the transformation matrix from picture space to affinity
void rectifyToAffinity(const Mat& imgOriginal, const CvMat* pts, CvMat* H_A, Mat& imgOut) {
  //get the input points(of a rectangle) for rectification
  //simply some pointers to points input
  //CvMat *pt1, *pt2, *pt3, *pt4;
  CvMat *pt1 = cvCreateMat(1, 3, CV_64FC1),
        *pt2 = cvCreateMat(1, 3, CV_64FC1),
        *pt3 = cvCreateMat(1, 3, CV_64FC1),
        *pt4 = cvCreateMat(1, 3, CV_64FC1);
  cvGetRow(pts, pt1, 0);
  cvGetRow(pts, pt2, 1);
  cvGetRow(pts, pt3, 2);
  cvGetRow(pts, pt4, 3);
  
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
  /*cout << "The two upper rectangle apexes:" << endl;
  cout << "(" << CV_MAT_ELEM(pt1, double, 0, 0)
  << ", " << CV_MAT_ELEM(pt1, double, 0, 1) << ")" << endl;
  cout << "(" << CV_MAT_ELEM(pt2, double, 0, 0)
  << ", " << CV_MAT_ELEM(pt2, double, 0, 1) << ")" << endl;*/
  cvCrossProduct(pt1, pt2, l1);
  /*cout << "The first parallel line: " << endl;
  cout << "(" << CV_MAT_ELEM(*l1, double, 0, 0)
  << ", " << CV_MAT_ELEM(*l1, double, 0, 1)
  << ", " << CV_MAT_ELEM(*l1, double, 0, 2) << ")" << endl;*/
  cvCrossProduct(pt3, pt4, l2);
  cvCrossProduct(pt1, pt3, m1);
  cvCrossProduct(pt2, pt4, m2);

  //calculating vanish line
  cvCrossProduct(l1, l2, v1);
  cvCrossProduct(m1, m2, v2);
  cvCrossProduct(v1, v2, vanishLine);

  // idea from https://engineering.purdue.edu/kak/computervision/ECE661.08/solution/hw2_s2.pdf
  // normalize vanishing line
  // in order to map the distorted image back to the image window
  double scale = 3.0;
  cvmSet(vanishLine, 0, 0, cvmGet(vanishLine, 0, 0) / cvmGet(vanishLine, 0, 2)*scale);
  cvmSet(vanishLine, 0, 1, cvmGet(vanishLine, 0, 1) / cvmGet(vanishLine, 0, 2)*scale);
  cvmSet(vanishLine, 0, 2, 1.0*scale);

  /*cout << "The vanishing line:" << endl;
  cout << "(" << CV_MAT_ELEM(*vanishLine, double, 0, 0)
  << ", " << CV_MAT_ELEM(*vanishLine, double, 0, 1)
  << ", " << CV_MAT_ELEM(*vanishLine, double, 0, 2) << ")" << endl;*/

  //CvMat *homo = cvCreateMat(3, 3, CV_64FC1);
  cvmSet(H_A, 0, 0, 1);
  cvmSet(H_A, 1, 1, 1);
  cvmSet(H_A, 2, 0, cvmGet(vanishLine, 0, 0));
  cvmSet(H_A, 2, 1, cvmGet(vanishLine, 0, 1));
  cvmSet(H_A, 2, 2, cvmGet(vanishLine, 0, 2));

  cv::warpPerspective(imgOriginal, imgOut, cvarrToMat(H_A), imgOriginal.size());
  cv::imwrite(".\\affinity.jpeg", imgOut);
  //cv::imshow("MyAffineTransform", myOut);
}

//====================================================================================================================================
//void affinityToNormal(const Mat& imgAffine, CvMat* pts, CvMat* H_A, Mat& result) {
//  // we assume the four input points are from apexes of a rectangle
//  // 0 1
//  // 2 3 then perpendicular line pairs include (01, 02), (03, 12)
//  CvMat *pt_tmp = cvCreateMat(1, 3, CV_64FC1);
//  for (int i = 0; i < 4; i++)
//  {
//    // get the current row of the input four points
//    CvMat* row = cvCreateMat(1, 3, CV_64FC1);
//    cvGetRow(pts, row, i);
//    // multiply the points with H_A
//    cvMatMul(H_A, row, pt_tmp);
//    // down scale the current point coordinates and put them into the pts array
//    cvmSet(pts, i, 0, ((int)(cvmGet(pt_tmp, 0, 0) / cvmGet(pt_tmp, 0, 2))));
//    cvmSet(pts, i, 1, ((int)(cvmGet(pt_tmp, 0, 1) / cvmGet(pt_tmp, 0, 2))));
//    cvmSet(pts, i, 2, 1.0);
//  }
//  // get all the affined points
//  CvMat *pt1 = cvCreateMat(1, 3, CV_64FC1),
//      *pt2 = cvCreateMat(1, 3, CV_64FC1),
//      *pt3 = cvCreateMat(1, 3, CV_64FC1),
//      *pt4 = cvCreateMat(1, 3, CV_64FC1);
//  cvGetRow(pts, pt1, 0);
//  cvGetRow(pts, pt2, 1);
//  cvGetRow(pts, pt3, 2);
//  cvGetRow(pts, pt4, 3);
//  // init all perpendicular lines
//  CvMat *l1 = cvCreateMat(1, 3, CV_64FC1),
//    *l2 = cvCreateMat(1, 3, CV_64FC1),
//    *m1 = cvCreateMat(1, 3, CV_64FC1),
//    *m2 = cvCreateMat(1, 3, CV_64FC1);
//  // cross product to get those lines
//  cvCrossProduct(pt1, pt2, l1);
//  cvCrossProduct(pt1, pt3, m1);
//  cvCrossProduct(pt1, pt4, l2);
//  cvCrossProduct(pt3, pt2, m2);
//  //coordinates of perpendicular lines
//  double l[2][2] = { {cvmGet(l1, 0, 0) , cvmGet(l1, 0, 1)},
//  {cvmGet(l2, 0, 0), cvmGet(l2, 0, 1) }
//  };
//  double m[2][2] = { { cvmGet(m1, 0, 0) , cvmGet(m1, 0, 1) },
//  { cvmGet(m2, 0, 0), cvmGet(m2, 0, 1) } 
//  };
//}
// TODO: maybe we want to use constant points
void affinityToNormal(const Mat& imgOriginal, CvMat* pts, CvMat* H_A, Mat& result) {
  Mat myOut;        // input image, output image after findHomo, my output

  myOut = imgOriginal.clone();
  //************** Metric Rectification *****************
  // transform points by H1
  CvMat *pt = cvCreateMat(1, 3, CV_64FC1);
  for (int i = 0; i < 4; i++)
  {
    CvMat *row = cvCreateMat(1, 3, CV_64FC1);
    // get a point
    cvGetRow(pts, row, i);
    /*cout << "The row:" << endl;
    cout << "(" << CV_MAT_ELEM(*row, double, 0, 0)
      << ", " << CV_MAT_ELEM(*row, double, 0, 1)
      << ", " << CV_MAT_ELEM(*row, double, 0, 2) << ")" << endl;*/
    // multiply with H_A to get it's coordinates in affinity and save in pt
    cvMatMul(row, H_A, pt);

    /*cout << "The row:" << endl;
    cout << "(" << CV_MAT_ELEM(*row, double, 0, 0)
    << ", " << CV_MAT_ELEM(*row, double, 0, 1)
    << ", " << CV_MAT_ELEM(*row, double, 0, 2) << ")" << endl;*/

    cvmSet(pts, i, 0, (int)(cvmGet(pt, 0, 0) / cvmGet(pt, 0, 2)));
    cvmSet(pts, i, 1, (int)(cvmGet(pt, 0, 1) / cvmGet(pt, 0, 2)));
    cvmSet(pts, i, 2, 1.0);
  }
  // get all the affined points
  CvMat *pt1 = cvCreateMat(1, 3, CV_64FC1),
    *pt2 = cvCreateMat(1, 3, CV_64FC1),
    *pt3 = cvCreateMat(1, 3, CV_64FC1),
    *pt4 = cvCreateMat(1, 3, CV_64FC1);
  cvGetRow(pts, pt1, 0);
  cvGetRow(pts, pt2, 1);
  cvGetRow(pts, pt3, 2);
  cvGetRow(pts, pt4, 3);

  //defining perpendicular lines
  /*CvMat *lines = cvCreateMat(4, 3, CV_64FC1);
  cvSetZero(lines);*/
  CvMat *l1 = cvCreateMat(1, 3, CV_64FC1),
    *l2 = cvCreateMat(1, 3, CV_64FC1),
    *m1 = cvCreateMat(1, 3, CV_64FC1),
    *m2 = cvCreateMat(1, 3, CV_64FC1);
  /*for (size_t i = 0; i < 4; i++)
  {
    CvMat *row; 
    cvGetRow(lines, row, i);
  }*/

  //get all the perpendicular lines
  //pairs: (l1, l2), (m1, m2)
  cvCrossProduct(pt1, pt2, l1);
  cvCrossProduct(pt1, pt3, m1);
  cvCrossProduct(pt1, pt4, l2);
  cvCrossProduct(pt3, pt2, m2);

  //coordinates of perpendicular lines
  double l[2][2] = { {cvmGet(l1, 0, 0) , cvmGet(l1, 0, 1)},
  {cvmGet(l2, 0, 0), cvmGet(l2, 0, 1) }
  };
  double m[2][2] = { { cvmGet(m1, 0, 0) , cvmGet(m1, 0, 1) },
  { cvmGet(m2, 0, 0), cvmGet(m2, 0, 1) } 
  };

  //according to coordinates of perpendicular lines, build the simultaneous linear equations
  double M_data[] = { l[0][0] * m[0][0], l[0][0] * m[0][1] + l[0][1] * m[0][0],
  l[1][0] * m[1][0], l[1][0] * m[1][1] + l[1][1] * m[1][0] };

  double b_data[] = { -l[0][1] * m[0][1], -l[1][1] * m[1][1] };

  CvMat *M = &(cvMat(2, 2, CV_64FC1, M_data));
  CvMat *b = &(cvMat(2, 1, CV_64FC1, b_data));
  CvMat *x = cvCreateMat(2, 1, CV_64FC1);
  cvSolve(M, b, x);

  // use SVD to solve S and get A
  // Set matrix S
  double Sdata[] = { cvmGet(x,0,0), cvmGet(x,1,0), cvmGet(x,1,0), 1.0 };
  CvMat S = cvMat(2, 2, CV_64FC1, Sdata);
  // SVD S=UDV_T
  CvMat* U = cvCreateMat(2, 2, CV_64FC1);
  CvMat* D = cvCreateMat(2, 2, CV_64FC1);
  CvMat* V = cvCreateMat(2, 2, CV_64FC1);
  cvSVD(&S, D, U, V, CV_SVD_U_T | CV_SVD_V_T);
  //The flags cause U and V to be returned transposed (does not work well
  //without the transpose flags).
  //Therefore, in OpenCV, S = U^T D V
   CvMat* U_T = cvCreateMat(2, 2, CV_64FC1);
  CvMat* sqrtD = cvCreateMat(2, 2, CV_64FC1);
  CvMat* A = cvCreateMat(2, 2, CV_64FC1);
  cvPow(D, sqrtD, 0.5);
  cvTranspose(U, U_T);
  cvMatMul(U_T, sqrtD, A);
  cvMatMul(A, V, A);
  // Set H2
  double t[] = { 0, 0 };
  double H2data[] = { cvmGet(A,0,0),cvmGet(A,0,1),t[0],
    cvmGet(A,1,0),cvmGet(A,1,1),t[1], 0,0,1 };
  CvMat H2 = cvMat(3, 3, CV_64FC1, H2data);
  CvMat *invH2 = cvCreateMat(3, 3, CV_64FC1);
  cvInvert(&H2, invH2);
  cv::warpPerspective(imgOriginal, myOut, cvarrToMat(invH2), imgOriginal.size());
  cv::imwrite(".\\normal.jpeg", myOut);
  //cvZero(check);
  //for (int i = 0; i < imgOriginal.cols; i++) { //y - ver
  //  for (int j = 0; j < imgOriginal.rows; j++) { //x - hor
  //                              // set X_a
  //    cvmSet(ptxp, 0, 0, (double)j);
  //    cvmSet(ptxp, 1, 0, (double)i);
  //    cvmSet(ptxp, 2, 0, 1.0);
  //    // compute X
  //    cvMatMul(invH2, ptxp, ptx);
  //    curpi = CLIP2(0, height - 1, (int)(cvmGet(ptx, 1, 0) / cvmGet(ptx, 2, 0)));
  //    curpj = CLIP2(0, width - 1, (int)(cvmGet(ptx, 0, 0) / cvmGet(ptx, 2, 0)));
  //    cvSet2D(img_scene, curpi, curpj, cvGet2D(img_affine, i, j));
  //    cvmSet(check, curpi, curpj, 1);
  //  }
  //}
  //// output reconstructed scene image
  //img_interp = cvCloneImage(img_scene);
  //data_interp = (uchar *)img_interp->imageData;
  ////interpolation
  //for (i = 1; i<height - 1; i++) { //y - ver
  //  for (j = 1; j<width - 1; j++) { //x - hor
  //    if (cvmGet(check, i, j) == 0) {
  //      count = (cvmGet(check, i -
  //        1, j) == 1) + (cvmGet(check, i + 1, j) == 1) + (cvmGet(check, i, j -
  //          1) == 1) + (cvmGet(check, i, j + 1) == 1);
  //      if (count != 0) {
  //        for (k = 0; k<channels; k++) {
  //          data_interp[i*step + j*channels + k] =
  //            (int)((data_scene[(i -
  //              1)*step + j*channels + k] + data_scene[(i + 1)*step + j*channels + k] + data_scene[i*step + (j -
  //                1)*channels + k] + data_scene[i*step + (j + 1)*channels + k]) / count);
  //        }
  //      }
  //    }
  //  }
  //}
  //if (!cvSaveImage("scene.jpg", img_interp))
  //  printf("Could not save file\n");

  //// release the image
  //cvReleaseImage(&img_in);
  //cvReleaseImage(&img_affine);
  //cvReleaseImage(&img_scene);
  //cvReleaseImage(&img_interp);
  //return 0;
}

//==========================================================================================================
void fourPointRectify(const Mat& imgOriginal, Mat& standardOut, Mat& fourPOut) {
  standardOut = imgOriginal.clone();
  fourPOut = imgOriginal.clone();

  int xy[4][2] = { { 1271, 546 },
  { 1626, 537 },
  { 1276, 936 },
  { 1619, 877 } };

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

  cv::warpPerspective(imgOriginal, standardOut, homography, imgOriginal.size());

  //cv::imshow("Original", imgOriginal);
  //cv::imshow("Rectified", standardOut);

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

  cv::warpPerspective(imgOriginal, fourPOut, my_homo, imgOriginal.size());

  //cv::imshow("MyTransform", fourPOut);

  waitKey(0);
}