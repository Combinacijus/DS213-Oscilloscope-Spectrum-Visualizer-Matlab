# DS213-Oscilloscope-Spectrum-Visualizer-Matlab
Matlab script to visualise Miniware DS213 Oscilloscope graph and its spectrum from csv file

<img src="https://github.com/Combinacijus/DS213-Oscilloscope-Spectrum-Visualizer-Matlab/assets/16375702/aeeab2b0-660b-42ef-bd1d-427d32098ac6" height="400" />
<img src="https://github.com/Combinacijus/DS213-Oscilloscope-Spectrum-Visualizer-Matlab/assets/16375702/b04b9a7a-169c-4421-922c-a87fdd0380c1" height="400" />

## How to use
1. Download `DS213_Spectrum_Visualizer.m` to some folder
2. With DS213 Oscilloscope record any number of CSV file (Square button -> Menu -> SaveCsv)

    ![image](https://github.com/Combinacijus/DS213-Oscilloscope-Spectrum-Visualizer-Matlab/assets/16375702/d954dfcb-dac3-43a1-bfa9-62d367d5dfd0)

4. Copy CSV files from DS213 to the same folder as `DS213_Spectrum_Visualizer.m`
5. Open script folder in Matlab
6. Run the file either with pressing Run button or by typing `DS213_Spectrum_Visualizer` to the Command Window
7. All CSV file will be detected automatically
8. On the side there is `Channel`, `Filename` and `Plot Percentage` and `FFT Separate` parameters to play with
    -  `Channel`: Which channel to plot A B C D. (C and D channels assume 1V/div because it's digital signal)
    -  `Filename`: All CSV files in current folder
    -  `Plot Percentage`: What percentage of all data to plot (DS213 records more data than it shows on the screen so at 100% signal gets squished)
    -  `FFT Separate`: If True spectrum will be calculated from all signal data. If False it will only use `Plot Percentage` of data

![image](https://github.com/Combinacijus/DS213-Oscilloscope-Spectrum-Visualizer-Matlab/assets/16375702/b04b9a7a-169c-4421-922c-a87fdd0380c1)

You can `Save As`, `Copy as Image` and `Copy as Vector Graphic` (my favorite) to save graph for you use case

![image](https://github.com/Combinacijus/DS213-Oscilloscope-Spectrum-Visualizer-Matlab/assets/16375702/51b16cde-1c1a-4e2d-9b0a-1a865b7ddd4a)

`Copy as Image` example

![image](https://github.com/Combinacijus/DS213-Oscilloscope-Spectrum-Visualizer-Matlab/assets/16375702/547fe315-649a-494e-8571-3bf1290c5262)


## Known limitations
- Y axis units and 0 dB mark might be misleading because I'm not sure how to calculate it correctly. But the relative form of the spectrum seems ok
- GUI could be improved
- Code could be cleaner and better organized
