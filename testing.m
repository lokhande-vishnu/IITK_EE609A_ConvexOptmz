% Testing
% Keep note of test set numbers and train set numbers

clear all;
close all;

load('Combined_Dictionary.mat');
load('alpha.mat');
alpha = a_lpha;
% alpha = ones(10,1);


% Parameters
N_patches = size(Combined_Dictionary,1);
N_classes = size(Combined_Dictionary,3);
N_trainclasses = 8;
b = {}; % Stores the PRRs for an image

% Preparing the test sets
count =1;
for sample_no = 9:10
    for class_no = 1:N_classes
        for patch_no = 1:N_patches
            test_image_patch{patch_no,count} = Combined_Dictionary{patch_no,sample_no,class_no};
        end
        test_target(1,count) = class_no;
        count = count+1;
    end
end
N_testimages = size(test_image_patch,2);


% Formation of PRRs for test images
% Only for Test samples
for test_idx = 1:N_testimages
    disp(test_idx)
    for patch_no = 1:N_patches
        for test_class = 1:N_classes   % Computing sparse representation for each class and find the residue
            
            diction = cell2mat(Combined_Dictionary(patch_no,1:N_trainclasses,test_class));
            b_eta = inv(diction'*diction)*diction'*test_image_patch{patch_no,test_idx};
            
            %                 cvx_begin
            %
            %                 variable b_eta(N_trainclasses)
            %                 minimize norm((test_image_patch-diction*b_eta),2)
            %
            %                 cvx_end
            
            r(patch_no,test_class) = norm((test_image_patch{patch_no,test_idx}-diction*b_eta),2);
            
            
        end
        delta = 0.1 * min(r(patch_no,:).^2);
        r_exp = exp(-r(patch_no,:).^2./delta);
        btk(patch_no,:) = r_exp./(sum(r_exp));
        b{test_idx} = btk';
    end
end


%Finding the classes
for test_idx = 1:N_testimages
    eta{test_idx} = b{test_idx}*alpha;
    [~,test_prediction(1,test_idx)] = max(eta{test_idx});
end

% Finding test accuracy
count_acc = 0;
for test_idx = 1:N_testimages
    if(test_prediction(1,test_idx) == test_target(1,test_idx))
        
        count_acc = count_acc+1;
    end
end
disp(count_acc*100/N_testimages)



