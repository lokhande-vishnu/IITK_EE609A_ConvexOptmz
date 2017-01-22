clear all

load('Dictionary.mat')

N_classes = 40;
%sample_no = [9,10];      % For testing purpose

N_columns_per_class = 8;


size_image = 112*92;

epsilon = 0.1;

residue = ones(N_classes,1);

count_acc = 0;

for class_no = 1:N_classes   % Taking an image at a time
    
    class_folder = strcat('s',int2str(class_no));
    
    for sample_no = 9:10    % Test samples
        
        sam_no = int2str(sample_no);
        filename = strcat(class_folder,'\',sam_no,'.pgm');
        image = imread(filename);
        test_image = reshape(image,size_image,1);    %test image in column form
        test_image = im2double(test_image);
        test_image = test_image./norm(test_image,2);   % Normalize the image
        
        
    
    for test_class = 1:N_classes   % Computing sparse representation for each class and find the residue
                
        diction = Combined_Dictionary(:,N_columns_per_class*(test_class-1)+1:N_columns_per_class*test_class);
        
       cvx_begin
        
       variable y(N_columns_per_class)
       minimize norm((test_image-diction*y),2)
     %  subject to
     %        norm((test_image-diction*y),2) <= epsilon  ;           
        
        
        cvx_end
        
       residue(test_class) = norm((test_image-diction*y),2);           
        
        
    end
    
    [min_residuevalue, class_identified] = min(residue);
    
     if(class_identified == class_no)               % Results/Matching of the class
         
         count_acc = count_acc+1;
     end
    
        
        
    end
    
    
    
    
end










