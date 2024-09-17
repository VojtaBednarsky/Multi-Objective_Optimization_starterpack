function num = customParetoPlot(fitness1, fitness2, cislo_iterace, num, iterace)

    % Resetuj graf a legendy pro první iteraci
    if cislo_iterace == 1
        clf;  % Vymaže graf
        legend('off');  % Vymaže legendy
        num = 0;
    else
        num = num + 1;
    end

    % Seznam různých markerů s různými tvary, barvami a velikostmi
    markers = {
        struct('shape', 'o', 'color', 'r', 'size', 6),
        struct('shape', 'x', 'color', 'b', 'size', 8),
        struct('shape', 's', 'color', 'g', 'size', 8),
        struct('shape', 'O', 'color', 'm', 'size', 5),
        struct('shape', 'd', 'color', 'k', 'size', 7),
        struct('shape', 'O', 'color', 'r', 'size', 3),
        struct('shape', 'o', 'color', 'g', 'size', 8),
        struct('shape', 'x', 'color', 'b', 'size', 4),
        struct('shape', 's', 'color', 'm', 'size', 3),
        struct('shape', 'x', 'color', 'g', 'size', 3),
        struct('shape', 'O', 'color', 'b', 'size', 3),
        struct('shape', 'd', 'color', 'c', 'size', 3)
    };

    % Zjistěte velikost matice fitness1
    [numPoints, ~] = size(fitness1);

    % Zobrazíme body Pareto fronty
    
%     fg = 22 + 0;
%     figure(fg);

    % Nastavení markeru pro vykreslování
    markerInfo = markers{mod(num, length(markers)) + 1};
    marker = markerInfo.shape;
    color = markerInfo.color;
    markerSize = markerInfo.size;

    for i = 1:numPoints
        plot(fitness1(i), fitness2(i), 'Marker', marker, 'MarkerSize', markerSize, 'MarkerEdgeColor', color, 'MarkerFaceColor', color);
        hold on;
    end

    xlabel('Area [mm^2]');
    ylabel('max|S11|');
    grid on;
    title(['Pareto Front - Iterace ', num2str(iterace)]);

    % Vytvoření legendy pro aktuální iteraci a zachování předchozích legend s různými tvary
    legendInfo = cell(num, 1);
    for iter = 1:2
        markerInfoIter = markers{mod(iter, length(markers)) + 1};
        markerIter = markerInfoIter.shape;
        legendInfo{iter} = ['Iterace ', num2str(iter), ' (', markerIter, ')'];
    end
%     legend(legendInfo, "AutoUpdate", "on");
%     hold on;
end
