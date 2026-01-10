classdef ToastConfig
    % TOASTCONFIG - Default Data & Configuration
    
    methods (Static)
        function products = getProducts()
            % Default Factory Data - Stocks are now int32
            products = [
                struct('ID', 1, 'Name', 'Cheese Toast', 'Price', 3.00, 'Stock', int32(10), 'ImageFile', 'prod_1.png', 'DetailImageFile', 'prod_detail_1.png');
                struct('ID', 2, 'Name', 'Sudzuk Toast', 'Price', 4.00, 'Stock', int32(10), 'ImageFile', 'prod_2.png', 'DetailImageFile', 'prod_detail_2.png');
                struct('ID', 3, 'Name', 'Mixed Toast',  'Price', 5.00, 'Stock', int32(10), 'ImageFile', 'prod_3.png', 'DetailImageFile', 'prod_detail_3.png');
                struct('ID', 4, 'Name', 'Turkish Tea',  'Price', 1.00, 'Stock', int32(20), 'ImageFile', 'prod_4.png', 'DetailImageFile', 'prod_detail_4.png');
                struct('ID', 5, 'Name', 'Ayran',        'Price', 1.00, 'Stock', int32(20), 'ImageFile', 'prod_5.png', 'DetailImageFile', 'prod_detail_5.png');
                struct('ID', 6, 'Name', 'Water',        'Price', 1.00, 'Stock', int32(20), 'ImageFile', 'prod_6.png', 'DetailImageFile', 'prod_detail_6.png');
            ];
        end
        
        function coins = getCoins()
            % Coins with ID, Value, and Stock (int32)
            coins = [
                struct('Val', 0.10, 'Stock', int32(50));
                struct('Val', 0.20, 'Stock', int32(50));
                struct('Val', 0.50, 'Stock', int32(50));
                struct('Val', 1.00, 'Stock', int32(50));
                struct('Val', 2.00, 'Stock', int32(50));
                struct('Val', 5.00, 'Stock', int32(20));
            ];
        end
        
        function files = getProcessImages()
            files.Idle   = 'process_idle.png';   
            files.Active = 'process_active.png'; 
        end
        
        function audio = getAudioFiles()
            audio.Cook = 'cook.mp3';
            audio.Fill = 'filling.mp3';
        end
        
        function colors = getTheme()
            colors.Background = '#364057'; 
            colors.DetailPanel = '#7c94f7'; 
            colors.Button = [0.4 0.4 0.45];    
            colors.ConfirmGreen = [0 0.7 0.3]; 
            colors.Green = [0 1 0];            
            colors.Text = [1 1 1];             
        end
        
        function pwd = getAdminPassword()
            pwd = '1234';
        end
    end
end
