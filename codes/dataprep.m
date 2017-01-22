% Randomly preparing the patches for every image
% Assigning desired targets for every image as well

clear all
close all

N_classes = 40;
N_columns_per_class = 10;
%N_samples_in_test = 2;

% Rows of Dictionary correspond to different patches and columns
% correpond to image number

Dictionary_train = {};
Dictionary_test = {};
Combined_Dictionary ={};

% patch co-ordinates
N_patches = 500;
a = randi([1 112],N_patches,2); %x co-ordinates,
b = randi([1 92],N_patches,2); %y co-ordinates,
x(:,1) = min(a,[],2); x(:,2) = max(a,[],2);
y(:,1) = min(b,[],2); y(:,2) = max(b,[],2);


count = 1;
for class_no = 1:N_classes
    disp (class_no)
    
    class_folder = strcat('orl_faces\s',int2str(class_no));
    
    for sample_no = 1:N_columns_per_class
        
        sam_no = int2str(sample_no);
        filename = strcat(class_folder,'\',sam_no,'.pgm');
        image = im2double(imread(filename));
        
        
        for patch_no = 1:N_patches
            temp = image(x(patch_no,1):x(patch_no,2),y(patch_no,1):y(patch_no,2));
            Combined_Dictionary{patch_no,sample_no,class_no} =  temp(:)./norm(temp(:),2);
        end
    end
end

% dictionary dim 1 = patches
% dictionary dim 2 = samples
% dictionary dim 3 = classes

save Combined_Dictionary.mat Combined_Dictionary

