function [desired_spread,result_perfp] = CV_GRNN(p_train,t_train,k,spreadMin,spreadMax)
%���������Ϊ����ֵ��
[m n]=size(p_train);
if m<

desired_spread=[];
mse_max=inf;
result_perfp=[];   
 
indices = crossvalind('Kfold',length(p_train),k);
%��spread���б�������
j=0;
for spread=spreadMin:0.01:spreadMax;
    perfp=[];
    j=j+1;
    for i = 1:k
        %�õ�k��CV��
        %�˴�testΪlogical���飬����������������
        test = (indices == i); train = ~test;
        p_cv_train=p_train(train,:);t_cv_train=t_train(train,:); p_cv_test=p_train(test,:);t_cv_test=t_train(test,:);
        %ת�ú���Ϊ��������Ϊ���������ں����һ��
        p_cv_train=p_cv_train';t_cv_train=t_cv_train';p_cv_test= p_cv_test';t_cv_test= t_cv_test';

        %��һ��
        [p_cv_train,trainPS,t_cv_train,trainLabelPS] = uniformF(p_cv_train,t_cv_train,1,0,1,0,1);
        %��ѵ��������ֵ��һ������Բ��Լ�����ֵ���й�һ��
        p_cv_test=mapminmax('apply',p_cv_test,trainPS);

        %����GRNN������
        net=newgrnn(p_cv_train,t_cv_train,spread);
        %������Լ�Ԥ����
        test_Out=sim(net,p_cv_test);
        %�Խ�����з���һ��
        test_Out=mapminmax('reverse',test_Out,trainLabelPS);
        %���Ԥ�⼯��mse
        error=t_cv_test-test_Out;
        %��¼������֤��mse����
        perfp=[perfp mse(error)];
    end
    result_perfp(j,:)=perfp;
    perfp=mean(abs(perfp));
    %�����Ų������и��£�Ĭ����������ȡ��С
    if perfp<mse_max
       mse_max=perfp;
       desired_spread=spread;
    end
end
end

