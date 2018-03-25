%**************************************************************************
%     图像检索——形状特征提取
%利用HU的七个不变矩作为形状特征向量
%Image : 输入图像数据
%n     : 返回七维形状特征行向量
%**************************************************************************
function n = Shape(Image)
% Image = imread('E:\\1\\1.jpg');
 [M,N,O] = size(Image);
%M = 256;
%N = 256;

%--------------------------------------------------------------------------
%彩色图像灰度化
%--------------------------------------------------------------------------
% Gray = double(0.3*Image(:,:,1)+0.59*Image(:,:,2)+0.11*Image(:,:,3));
Gray=Image;
%--------------------------------------------------------------------------
%用Canny边缘检测提取边缘保留边缘灰度图像
%--------------------------------------------------------------------------
% BW = uint8(edge(Gray,'canny'));
% Egray = uint8(edge(Gray,'canny'));
% for i = 1:M
%     for j = 1:N
%         if Egray(i,j)==0
%             Gray(i,j)=0;
%         end
%     end
% end

%--------------------------------------------------------------------------
%Otsu提出的类判别分析法自动为每一幅廓图像选定阈值，然后用该阈值对图像二值化
%--------------------------------------------------------------------------
%计算灰度级归一化直方图
for i = 0:255
    h(i+1) = size(find(Gray==i),1);
end
p = h/sum(h);
%计算灰度均值
ut = 0;
for i = 0:255
    ut = i*p(i+1)+ut;
end
%计算直方图的零阶累积矩和一阶累积矩：
for k = 0:254
    w(k+1) = sum(p(1:k+1));
    u(k+1) = sum((0:k).*p(1:k+1));
end
%计算类分离指标
deltaB = zeros(1,255);
for k = 0:254    
    if w(k+1)~=0&w(k+1)~=1
        deltaB(k+1) = (ut*w(k+1)-u(k+1))^2/(w(k+1)*(1-w(k+1)));
    end
end
[value,thresh] = max(deltaB);
% deltaB = zeros(1,255);
% delta1 = zeros(1,255);
% delta2 = zeros(1,255);
% deltaW = zeros(1,255);
% for k = 0:254
%     if w(k+1)~=0&w(k+1)~=1
%         deltaB(k+1) = (ut*w(k+1)-u(k+1))^2/(w(k+1)*(1-w(k+1)));
%         delta1(k+1) = 0;
%         delta2(k+1) = 0;
%         for i = 0:k
%             delta1(k+1) = (i-u(k+1)/w(k+1))^2*p(i+1)+delta1(k+1);
%         end
%         for i = k+1:255
%             delta2(k+1) = (i-(ut-u(k+1))/(1-w(k+1)))^2*p(k+1)+delta2(k+1);
%         end
%         deltaW(k+1) = delta1(k+1)+delta2(k+1);
%     end
% end
% for i = 1:255
%     if deltaB==0
%         yita=0;
%     else
%         yita(i) = 1/(1+deltaW(i)./deltaB(i));
%     end
% end
% % D的最大值作为最佳阈值
% [value,thresh] = max(yita);

%对图像二值化
for i = 1:M
    for j = 1:N
        if Gray(i,j)>=thresh
            BW(i,j) = 1;
        else
            BW(i,j) = 0;
        end
    end
end

%--------------------------------------------------------------------------
%计算图像质心:(I,J)
%--------------------------------------------------------------------------
m00 = sum(sum(BW)); %零阶矩
m01 = 0;              %一阶矩 
m10 = 0;              %一阶矩
for i = 1:M
    for j = 1:N
        m01 = BW(i,j)*j+m01;
        m10 = BW(i,j)*i+m10;
    end
end
I = (m10)/(m00);
J = m01/m00;

%--------------------------------------------------------------------------
%中心矩：
%--------------------------------------------------------------------------
u11 = 0;
u20 = 0; u02 = 0;
u30 = 0; u03 = 0;
u12 = 0; u21 = 0;
for i = 1:M
    for j = 1:N
        u20 = BW(i,j)*(i-I)^2+u20;
        u02 = BW(i,j)*(j-J)^2+u02;
        u11 = BW(i,j)*(i-I)*(j-J)+u11;
        u30 = BW(i,j)*(i-I)^3+u30;
        u03 = BW(i,j)*(j-J)^3+u03;
        u12 = BW(i,j)*(i-I)*(j-J)^2+u12;
        u21 = BW(i,j)*(i-I)^2*(j-J)+u21;
    end
end
u20 = u20/m00^2;
u02 = u02/m00^2;
u11 = u11/m00^2;
u30 = u30/m00^(5/2);
u03 = u03/m00^(5/2);
u12 = u12/m00^(5/2);
u21 = u21/m00^(5/2);
%--------------------------------------------------------------------------
%7个Hu不变矩：
%--------------------------------------------------------------------------
n(1) = u20+u02;
n(2) = (u20-u02)^2+4*u11^2;
n(3) = (u30-3*u12)^2+(u03-3*u21)^2;
n(4) = (u30+u12)^2+(u03+u21)^2;
n(5) = (u30-3*u12)*(u30+u12)*((u30+u12)^2-3*(u03-3*u21)^2)+(u03-3*u21)*(u03+u21)*((u03+u21)^2-3*(u30+u12)^2);
n(6) = (u20-u02)*((u30+u12)^2-(u03+u21)^2)+4*u11*(u30+u12)*(u03+u21);
n(7) = (3*u21-u03)*(u30+u12)*((u30+u12)^2-3*(u03-3*u21)^2)+(u30-3*u21)*(u03+u21)*((u03+u21)^2-3*(u30+u12)^2);
% %--------------------------------------------------------------------------
% %内部归一化：
% %--------------------------------------------------------------------------
% en = mean(n);
% delta = sqrt(cov(n));
% n = abs(n-en)/(3*delta);