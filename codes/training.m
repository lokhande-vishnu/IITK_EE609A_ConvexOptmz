% Training

clear all;
close all;


load('Combined_Dictionary.mat');
N_patches = size(Combined_Dictionary,1);
N_classes = size(Combined_Dictionary,3);
N_trainclasses = 8;

% Preparing the train dat sets
count =1;
for sample_no = 1:8
    for class_no = 1:N_classes
        for patch_no = 1:N_patches
            train_image_patch{patch_no,count} = Combined_Dictionary{patch_no,sample_no,class_no};
        end
        train_target(1,count) = class_no;
        sample_note(1,count) = sample_no; % Keeping note of sample number for leave-one-out preparation
        count = count+1;
    end
end
N_trainimages = size(train_image_patch,2);


% Formation of PRRs for train images
% Using leave-one-out approach
for train_idx = 1:N_trainimages
    disp(train_idx)
    for patch_no = 1:N_patches
        for test_class = 1:N_classes   % Computing sparse representation for each class and find the residue
            
            if (test_class == train_target(1,train_idx))
                
                diction = cell2mat(Combined_Dictionary(patch_no,1:N_trainclasses,test_class));
                diction(:,sample_note(1,train_idx)) = [];
                % b_eta = inv(diction'*diction)*diction'*train_image_patch{patch_no,train_idx};
                
                cvx_begin
                
                variable b_eta(N_trainclasses-1)
                minimize norm((train_image_patch{patch_no,train_idx}-diction*b_eta),2)
                
                cvx_end
                
                r(patch_no,test_class) = norm((train_image_patch{patch_no,train_idx}-diction*b_eta),2);
                
            else
                diction = cell2mat(Combined_Dictionary(patch_no,1:N_trainclasses,test_class));
                % b_eta = inv(diction'*diction)*diction'*train_image_patch{patch_no,train_idx};
                
                cvx_begin
                
                variable b_eta(N_trainclasses)
                minimize norm((train_image_patch{patch_no,train_idx}-diction*b_eta),2)
                
                cvx_end
                
                r(patch_no,test_class) = norm((train_image_patch{patch_no,train_idx}-diction*b_eta),2);
            end
            
        end
        delta = 0.1 * min(r(patch_no,:).^2);
        r_exp = exp(-r(patch_no,:).^2./delta);
        btk(patch_no,:) = r_exp./(sum(r_exp));
        b{train_idx} = btk';
    end
end


% Optimisation to find alpha

cvx_begin
variables a_lpha(N_patches,1) t(N_trainimages,1)
temp1 = cvx(zeros(1,1));
temp2 = cvx(zeros(N_trainimages,1));

for train_idx = 1:N_trainimages
    for patch_no = 1:N_patches
        temp1 = temp1 + a_lpha(patch_no,1)*((b{train_idx}(train_target(1,train_idx),patch_no)) - 1/N_classes );
    end
    temp2(train_idx,1) = temp1;
end

min(sum(t))
subject to
t >= exp(-temp2);
t >= 0;
% temp2 >= -log(t);
a_lpha >= 0;
norm(a_lpha,1) <= 1;

cvx_end
cvx_clear


save alpha.mat a_lpha



