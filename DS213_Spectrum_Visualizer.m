function DS213_Spectrum_Visualizer()
    files = dir('*.csv');
    filename_list = {files.name};
    percentage_to_plot = 100;  % Percentage of how many values to plot
    fft_separate = 1;
    
    hFig = figure('Position', [100, 50, 1100, 700], 'Name', 'DS213 Osciloscope Spectrum Analyzer', 'NumberTitle', 'off');
    
    % Axes for time-domain and frequency-domain plots
    hAxTime = subplot(2,1,1);
    hAxFreq = subplot(2,1,2);
    
    fig_pos = get(gcf, 'Position');
    fig_w = fig_pos(3);

    % Get current positions
    posTime = get(hAxTime, 'Position');
    posFreq = get(hAxFreq, 'Position');
    
    % Calculate total horizontal shift in normalized units
    totalShift = 50 / fig_w;
    
    % Adjust positions by adding 100 pixels to the 'left'
    adjustedLeft = posTime(1) + 100/fig_w; 
    posTime(1) = adjustedLeft;
    posFreq(1) = adjustedLeft;
    
    % Reduce the width of the subplots to prevent clipping and to add the margin
    posTime(3) = posTime(3) - totalShift;
    posFreq(3) = posFreq(3) - totalShift;
    
    % Set new positions
    set(hAxTime, 'Position', posTime);
    set(hAxFreq, 'Position', posFreq);
    
    % List for channel and file selection
    uicontrol('Style', 'text', 'String', 'Channel:', 'Position', [10, 580, 60, 20]);
    listbox_channel = uicontrol('Style', 'listbox', 'String', {'A', 'B', 'C', 'D'}, 'Position', [10, 490, 60, 80], 'Callback', @(src,event)updatePlots(), 'Value', 2);
    
    uicontrol('Style', 'text', 'String', 'Filename:', 'Position', [10, 460, 150, 20]);
    listbox_filename = uicontrol('Style', 'listbox', 'String', filename_list, 'Position', [10, 380, 150, 80], 'Callback', @(src,event)updatePlots(), 'Value', 1);
    
    uicontrol('Style', 'text', 'String', 'Plot Percentage:', 'Position', [1, 350, 150, 20]);
    % slider_plot_percentage = uicontrol('Style', 'slider', 'Min', 1, 'Max', 100, 'Value', percentage_to_plot, 'SliderStep', [1/99, 1/10], 'Position', [10, 320, 150, 20], 'Callback', @(src,event)updatePlots());
    numList = arrayfun(@(x) num2str(x), [5 10 25 50 100], 'UniformOutput', false);
    slider_plot_percentage = uicontrol('Style', 'listbox', 'String', numList, 'Position', [10, 270, 60, 80], 'Callback', @(src,event)updatePlots(), 'Value', 2);

    % Add checkbox for fft_separate
    uicontrol('Style', 'text', 'String', 'FFT Separate:', 'Position', [10, 240, 100, 20]);
    checkbox_fft_separate = uicontrol('Style', 'checkbox', 'Position', [110, 240, 20, 20], 'Callback', @(src,event)updatePlots(), 'Value', 1);

    function updatePlots()
        % Get listbox selections
        selectedChannel = get(listbox_channel, 'Value');
        filename = listbox_filename.String{get(listbox_filename, 'Value')};
        % percentage_to_plot = slider_plot_percentage.Value;
        percentage_str = slider_plot_percentage.String{get(slider_plot_percentage, 'Value')};
        percentage_to_plot = str2double(percentage_str);
        fft_separate = get(checkbox_fft_separate, 'Value');

        % Process CSV data
        [time, data, frequencies, spectrum, volt_div, sample_period, plot_range] = process_csv(filename);

        % ------------------------Plot signal  ------------------------
        axes(hAxTime);
        cla;
        timeLabel = 'Laikas, s';
        
        % Check the range of time values
        timeMax = max(time(plot_range));

        if timeMax < 1e-6  % less than 1 microsecond
            timeDisplay = time(plot_range) * 1e9;  % convert to ns
            timeLabel = 'Laikas, ns';
        elseif timeMax < 1e-3  % less than 1 millisecond
            timeDisplay = time(plot_range) * 1e6;  % convert to us
            timeLabel = 'Laikas, us';
        elseif timeMax < 1  % less than 1 second
            timeDisplay = time(plot_range) * 1e3;  % convert to ms
            timeLabel = 'Laikas, ms';
        else
            timeDisplay = time(plot_range);  % leave as seconds
            timeLabel = 'Laikas, s';
        end
        plot(timeDisplay, data(plot_range, selectedChannel), 'k', 'LineWidth', 1, 'Color', [0, 0, 0, 1]);
        % title(['Channel ', char(selectedChannel+64), ' Waveform']);
        xlabel(timeLabel);
        ylabel('Įtampa, V');
        grid on;

        % --------------------- Plot frequency spectrum -------------------
        axes(hAxFreq);
        cla;
        plot(frequencies, spectrum(:, selectedChannel), 'k', 'LineWidth', 0.75)
        % semilogy(frequencies, spectrum(:, selectedChannel), 'k', 'LineWidth', 0.75);
        % Adjust y-axis limits
        maxValue = max(spectrum(:, selectedChannel));
        minValue = min(spectrum(:, selectedChannel));
        value_offset = 10;
        
        upperBound = max(maxValue-value_offset, 0);
        lowerBound = min(minValue+value_offset, -120);
        
        % hAx = gca;  % Get current axes handle
        % hAx.FontWeight = 'bold';  % Set the FontWeight property to bold
        % hAx.FontSize = hAx.FontSize + 1;  % Increase the font size slightly

        ylim([lowerBound upperBound]);
        % title(['Channel ', char(selectedChannel+64), ' Spectrum']);
        xlabel('Dažnis, Hz', 'FontWeight', 'bold');
        ylabel('dB', 'FontWeight', 'bold');
        xlim([0, 16000]);
        grid on;
    end

    function [time, data, frequencies, spectrum, volt_div, sample_period, plot_range] = process_csv(filename)
        fid = fopen(filename, 'rt');
        headerLine = fgetl(fid);
        fclose(fid);
    
        headers = strsplit(headerLine, ',');
    
        volt_div = nan(1, 4); % Initialize volt_div to handle missing columns
        
        % Extract volt_div for channels A and B
        for i = 1:2
            header = headers{i};
            voltValueStr = regexp(header, '(\d+(\.\d+)?)(?=\s*V)', 'match'); % This regex extracts floating-point numbers

            if ~isempty(voltValueStr)
                volt_div(i) = str2double(voltValueStr{1});
            end
        end
        
        % For channels C and D, which are logic signals
        volt_div(3:4) = 1;
    
        % Extract time per division and later sample_period
        timeHeader = headers{contains(headers, 'T_BASE')};
        timeValueStr = regexp(timeHeader, '\d+(\.\d+)?', 'match');
        time_unit = regexp(timeHeader, '(?<=T_BASE\s*\d+(\.\d+)?)[numS]{1}', 'match');
        
        samples_per_div = 30;
        multiplier = get_time_multiplier(time_unit{1});
        sample_period = str2double(timeValueStr{1}) * multiplier / samples_per_div;
        
        % Read the data
        rawData = rmmissing(readtable(filename, 'HeaderLines', 1));
        if any(isnan(volt_div))
            warning(['Can not extract volt_div from: ', mat2str(volt_div)]);
        end
        
        % Convert 8-bit values to voltage
        for i = 1:4
            if i <= width(rawData)  % Check if the channel exists in the CSV
                data(:, i) = (rawData{:, i} - 100) / 255 * volt_div(i) * 8;
            end
        end
        
        time = (0:(size(rawData, 1) - 1)) * sample_period;

        % Set plot range from percentage_to_plot
        if exist('percentage_to_plot', 'var')
            percentage_to_plot = min(percentage_to_plot, 100);
            plot_range = 1:round(percentage_to_plot / 100 * length(time));
        else
            plot_range = 1:length(time);
        end

        if fft_separate
            spectrum = abs(fft(data)) * sample_period;
        else
            spectrum = abs(fft(data(plot_range, :))) * sample_period;
        end

        spectrum_normalized = spectrum / max(spectrum(:)); % Normalizing the spectrum by its maximum value
        spectrum_dB = 20 * log10(spectrum_normalized); % Converting to dB with peak at 0 dB
        spectrum = spectrum_dB;
        
        frequencies = linspace(0, 1/sample_period, size(spectrum, 1));
    end
    
    function multiplier = get_time_multiplier(unit)
        switch unit
            case 'n'
                multiplier = 1e-9;
            case 'u'
                multiplier = 1e-6;
            case 'm'
                multiplier = 1e-3;
            otherwise
                multiplier = 1;
        end
    end

    % Call updatePlots to initialize
    updatePlots();
end
