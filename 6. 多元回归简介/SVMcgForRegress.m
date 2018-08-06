%% �Ӻ��� SVMcgForRegress.m
%��һ����Χ��ѡ��Ƚϲ����֧������������
%train_label train
%cmin cmax c�����������С��Χ 2^cmin~2^cmax 
%gmin gmax g�����������С��Χ 2^gmin~2^gmax 
% v ������֤�ֿ���
% cstep,gstep c,g�����仯����
% msestep ��ʾ׼ȷ�ʵ�ͼ�Ĳ�����С
function [mse,bestc,bestg] = SVMcgForRegress(train_label,train,cmin,cmax,gmin,gmax,v,cstep,gstep,msestep)
%%nargin �жϱ����ĸ�������Ĭ��ֵ
if nargin < 10  msestep = 0.06;             end
if nargin < 8   cstep = 0.8;gstep = 0.8;    end
if nargin < 7   v = 5;                      end
if nargin < 5   gmax = 8;   gmin = -8;      end
if nargin < 3   cmax = 8;   cmin = -8;      end

% X:c Y:g cg:acc
[X,Y] = meshgrid(cmin:cstep:cmax,gmin:gstep:gmax);
%c��������m��ѡ�g��������n��ѡ��
[m,n] = size(X);
%�ֱ��¼ÿ����ͬ��cg��ϵĽ��
cg = zeros(m,n);

eps = 10^(-4);
%�������������ֵ
bestc = 0;bestg = 0;mse = Inf;
%����2Ϊ�׵Ĳ�������
basenum = 2;
for i = 1:m
    for j = 1:n
        %-v ������֤ģʽ����ļ򵥷��㣡�� -c -g -s����epsilon-SVRģ��
        %-p����epsilonģ�͵���ʧ����Ĭ��0.001
        cmd = ['-v ',num2str(v),' -c ',num2str( basenum^X(i,j) ),' -g ',num2str( basenum^Y(i,j) ),' -s 3 -p 0.1'];
        %�ڽ�����֤ģʽ�·��ص��ǽ�����֤��ƽ�����������mse
        cg(i,j) = svmtrain(train_label, train, cmd);
        %�����Ų������и���
        if cg(i,j) < mse
            mse = cg(i,j);
            bestc = basenum^X(i,j);
            bestg = basenum^Y(i,j);
        end
        %����
        if abs( cg(i,j)-mse )<=eps && bestc > basenum^X(i,j)
            mse = cg(i,j);
            bestc = basenum^X(i,j);
            bestg = basenum^Y(i,j);
        end
    end
end
% ���ȸ���ͼ�Լ���դͼ
[cg,ps] = mapminmax(cg,0,1);
figure;
[C,h] = contour(X,Y,cg,0:msestep:0.5);
clabel(C,h,'FontSize',10,'Color','r');
xlabel('log2c','FontSize',12);
ylabel('log2g','FontSize',12);
firstline = 'SVR����ѡ����ͼ(�ȸ���ͼ)[GridSearchMethod]'; 
secondline = ['Best c=',num2str(bestc),' g=',num2str(bestg),'CVmse=',num2str(mse)];
title({firstline;secondline},'Fontsize',12);
grid on;

figure;
meshc(X,Y,cg);
axis([cmin,cmax,gmin,gmax,0,1]);
xlabel('log2c','FontSize',12);
ylabel('log2g','FontSize',12);
zlabel('MSE','FontSize',12);
firstline = 'SVR����ѡ����ͼ(3D��ͼ)[GridSearchMethod]'; 
secondline = ['Best c=',num2str(bestc),' g=',num2str(bestg),' CVmse=',num2str(mse)];
title({firstline;secondline},'Fontsize',12);
end