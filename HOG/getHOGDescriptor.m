function [descriptor, histogram] = getHOGDescriptor(image,cellSize,bins, signedUnsigned)

%% Getting magnitude and direction of the gradients

original = image;
image = single(image);
[rho,theta] = getGradientFromImage(image);
theta(theta<0) = theta(theta<0)+(180);

%% Gettings the cells

cellsInX = numel(cellSize(1):cellSize(1):size(image,1));
cellsInY = numel(cellSize(2):cellSize(2):size(image,2));
totalCells = cellsInX*cellsInY;

cellsMagnitude = zeros(cellSize(1),cellSize(2),totalCells);
cellsDirection = zeros(cellSize(1),cellSize(2),totalCells);

cell = 1;
for x = 1:cellSize(1):size(image,1)
    for  y = 1:cellSize(2):size(image,2);
        cellsMagnitude(:,:,cell) = rho(x:x+7,y:y+7);
        cellsDirection(:,:,cell) = theta(x:x+7,y:y+7);
        cell = cell + 1;
    end
end

%% Getting the histograms

if(signedUnsigned)
    base = 0:40:320; %signed
else
    base = 0:20:160; %unsigned
end    
    
hist = zeros(totalCells,bins);

for c = 1:totalCells
    for x = 1:cellSize(1)
       for y = 1:cellSize(1)
           pos = ismember(base,cellsDirection(x,y,c)); 
           if any(pos)
               pos = pos*cellsMagnitude(x,y,c);
               hist(c,:) = hist(c,:) + pos;
           else
               d = cellsDirection(x,y,c);
               magnitude = cellsMagnitude(x,y,c);
               switch logical(true)
                   case d > base(1) & d < base(2)
                       [hist(c,1),hist(c,2)] = getBalancedDirectionAndMagnitude(base(1),base(2),d,magnitude);
                   case d > base(2) & d < base(3)
                       [hist(c,2),hist(c,3)] = getBalancedDirectionAndMagnitude(base(2),base(3),d,magnitude);
                   case d > base(3) & d < base(4)
                       [hist(c,3),hist(c,4)] = getBalancedDirectionAndMagnitude(base(3),base(4),d,magnitude);
                   case d > base(4) & d < base(5)
                       [hist(c,4),hist(c,5)] = getBalancedDirectionAndMagnitude(base(4),base(5),d,magnitude);
                   case d > base(5) & d < base(6)
                       [hist(c,5),hist(c,6)] = getBalancedDirectionAndMagnitude(base(5),base(6),d,magnitude);
                   case d > base(6) & d < base(7)
                       [hist(c,6),hist(c,7)] = getBalancedDirectionAndMagnitude(base(6),base(7),d,magnitude);
                   case d > base(7) & d < base(8)
                       [hist(c,7),hist(c,7)] = getBalancedDirectionAndMagnitude(base(7),base(8),d,magnitude);
                   case d > base(8) & d < base(9)
                       [hist(c,8),hist(c,9)] = getBalancedDirectionAndMagnitude(base(8),base(9),d,magnitude);
                   otherwise
                        if(signedUnsigned)
                            [hist(c,9),hist(c,1)] = getBalancedDirectionAndMagnitude(base(9),base(1)+360,d,magnitude);
                        else
                            [hist(c,9),hist(c,1)] = getBalancedDirectionAndMagnitude(base(9),base(1)+180,d,magnitude);
                        end
               end
           end
       end
    end
end

%% Mounting the descriptor

descriptor = [];
aux = 1;
histaux = zeros(size(hist));

for k = 1:(totalCells)-17
    if(aux > 15)
        aux = 1;
        k = k +1;
        continue;
    end
    normValue = norm([hist(k,:) ; hist(k+1,:) ; hist(k+16,:) ; hist(k+17,:)]);
    if normValue ~= 0   
        histaux(k,:) = hist(k,:)/normValue;
        histaux(k+1,:) = hist(k+1,:)/normValue;
        histaux(k+16,:) = hist(k+16,:)/normValue;
        histaux(k+17,:) = hist(k+17,:)/normValue;
    end
    descriptor = [descriptor ; histaux(k,:)' ; histaux(k+1,:)' ; histaux(k+16,:)' ; histaux(k+17,:)'];
    aux = aux + 1;
end

histogram = histaux;

% Umcomment this to print the visualization of the descriptors over the
% images
% getDescriptorVisualization(original,histaux);

end

