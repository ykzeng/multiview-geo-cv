clear all
clc

load('points.mat');
Image_A = pts_img_2;
Image_B = pts_img_1;

% figure(1); imshow('pics\pic1.jpg');
% hold on;
% 
% for i = 1 : 20
%     h = plot(pts_img_1(i, 1), pts_img_1(i, 2), 'x', 'Color', 'r', 'MarkerSize', 10);
%     set(h, 'linewidth', 3);
% end

%figure(1); imshow('pics\pic2.jpg');
% hold on;
% 
% for i = 1 : 20
%     h = plot(pts_img_2(i, 1), pts_img_2(i, 2), 'x', 'Color', 'r', 'MarkerSize', 10);
%     set(h, 'linewidth', 3);
% end

T=[2/2500,0,-1;0,2/1875,-1;0,0,1];
T2=[2/1875,0,-1;0,2/2500,-1;0,0,1];
Image_AA=(T*[Image_A';ones(1,20)])';
Image_BB=(T2*[Image_B';ones(1,20)])';
for i=1:20
    A(i,:)=[Image_BB(i,1)*Image_A(i,1),Image_BB(i,1)*Image_AA(i,2),Image_BB(i,1),Image_BB(i,2)*Image_AA(i,1),Image_BB(i,2)*Image_AA(i,2),Image_BB(i,2),Image_AA(i,1),Image_AA(i,2),1];
end
    
[U,S,V]=svd(A);
null(A');
F=V(:,9);
F=(reshape(F,[3,3]))';
[u,s,v]=svd(F);

s(3,3)=0;
F2=u*s*v';
F=T2'*F2*T;

e_2=null(F');
skew_e_2=[0,-e_2(3),e_2(2);e_2(3),0,-e_2(1);-e_2(2),e_2(1),0];
P_2=[skew_e_2*F,e_2];
P_1=[1,0,0,0;0,1,0,0;0,0,1,0];

for i=1:20
A_X(1,:)=Image_A(i,1)*P_1(3,:)-P_1(1,:);
A_X(2,:)=Image_A(i,2)*P_1(3,:)-P_1(2,:);
A_X(3,:)=Image_B(i,1)*P_2(3,:)-P_2(1,:);
A_X(4,:) =Image_B(i,2)*P_2(3,:)-P_2(2,:);
[u2,s2,v2]=svd(A_X);
X(:,i)=v2(:,4)';
end

line1_1=cross([Image_A(1,:),1],[Image_A(4,:),1]);
line1_2=cross([Image_A(5,:),1],[Image_A(8,:),1]);
vanish1_1=cross(line1_1,line1_2);
vanish2_1=F*vanish1_1';
line2_1=cross([Image_B(1,:),1],[Image_B(4,:),1]);
vanish3_1=cross(vanish2_1,line2_1);

skew_v_1=[0,-vanish3_1(3),vanish3_1(2);vanish3_1(3),0,-vanish3_1(1);-vanish3_1(2),vanish3_1(1),0];
Vanish1=[skew_v_1*P_1;line2_1*P_2];
Space_vanish_point1=null(Vanish1);



line1_3=cross([Image_A(1,:),1],[Image_A(5,:),1]);
line1_4=cross([Image_A(4,:),1],[Image_A(8,:),1]);
vanish1_2=cross(line1_3,line1_4);
vanish2_2=F*vanish1_2';
line2_2=cross([Image_B(1,:),1],[Image_B(5,:),1]);
vanish3_2=cross(vanish2_2,line2_2);

skew_v_2=[0,-vanish3_2(3),vanish3_2(2);vanish3_2(3),0,-vanish3_2(1);-vanish3_2(2),vanish3_2(1),0];
Vanish2=[skew_v_2*P_1;line2_2*P_2];
Space_vanish_point2=null(Vanish2);

line1_5=cross([Image_A(11,:),1],[Image_A(14,:),1]);
line1_6=cross([Image_A(15,:),1],[Image_A(18,:),1]);
vanish1_3=cross(line1_3,line1_4);
vanish2_3=F*vanish1_3';
line2_3=cross([Image_B(11,:),1],[Image_B(14,:),1]);
vanish3_3=cross(vanish2_3,line2_3);


skew_v_3=[0,-vanish3_3(3),vanish3_3(2);vanish3_3(3),0,-vanish3_3(1);-vanish3_3(2),vanish3_3(1),0];
Vanish3=[skew_v_3*P_1;line2_3*P_2];
Space_vanish_point3=null(Vanish3);


infinity_pai=null([Space_vanish_point1';Space_vanish_point2';Space_vanish_point3']);

H=[1,0,0,0;0,1,0,0;0,0,1,0;infinity_pai'];

X=H*X;
for i=1:4
X(i,:)=X(i,:)./X(4,:);
end

scatter3(X(1,:),X(2,:),X(3,:))

plane1=null([X(:,1)';X(:,4)';X(:,5)'])
plane2=null([X(:,11)';X(:,14)';X(:,15)'])
plane1'
plane2'
