% Building Dictionary
clear all
% 40 Classes
N_classes = 40;
N_columns_per_class = 8;

size_image = 112*92;

Combined_Dictionary = zeros(size_image,N_classes*N_columns_per_class);

count = 1;

for class_no = 1:N_classes
    
    class_folder = strcat('orl_faces\s',int2str(class_no));
    
    for sample_no = 1:N_columns_per_class
        
        sam_no = int2str(sample_no);
        filename = strcat(class_folder,'\',sam_no,'.pgm');
        image = imread(filename);
        atom_dict = reshape(image,size_image,1);
        atom_dict = im2double(atom_dict);           % Normalize the image
        atom_dict = atom_dict./norm(atom_dict,2);
        
        
        Combined_Dictionary(:,count) = atom_dict;
        count = count+1;
        
    end
    
end








