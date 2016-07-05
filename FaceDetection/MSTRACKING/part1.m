% ----------------------------------------------------------------------
% - CSE 486
% - Project 5
% - Group 8
% - idg101, adi102, jlm522
% ----------------------------------------------------------------------

% Part 1

cd frames;

for i = 1:15,
    filename1 = sprintf('%3.3i.png', i);
    filename2 = sprintf('%3.3i.png', i-1);
    A = imread(filename1, 'png');
    A = RGB2GRAY(A);
    
    B = imread(filename2, 'png');
    B = RGB2GRAY(B);
    
    C = imabsdiff(A,B);
    imwrite(C, sprintf('%3.3i-%3.3i.png', i, i-1), 'png');
end

cd ..

disp('Done.');