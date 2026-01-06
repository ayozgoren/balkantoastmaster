classdef ToastConfig
    
    methods (Static)
        function products = getProducts()
            % Product list with Images
            products = [
                struct('Name', 'Cheese Toast', 'Price', 3.00, 'ID', 1, 'ImageFile', 'prod_1.png', 'DetailImageFile', 'prod_detail_1.png');
                struct('Name', 'Sudzuk Toast', 'Price', 4.00, 'ID', 2, 'ImageFile', 'prod_2.png', 'DetailImageFile', 'prod_detail_2.png');
                struct('Name', 'Mixed Toast',  'Price', 5.00, 'ID', 3, 'ImageFile', 'prod_3.png', 'DetailImageFile', 'prod_detail_3.png');
                struct('Name', 'Turkish Tea',  'Price', 1.00, 'ID', 4, 'ImageFile', 'prod_4.png', 'DetailImageFile', 'prod_detail_4.png');
                struct('Name', 'Ayran',        'Price', 1.00, 'ID', 5, 'ImageFile', 'prod_5.png', 'DetailImageFile', 'prod_detail_5.png');
                struct('Name', 'Water',        'Price', 1.00, 'ID', 6, 'ImageFile', 'prod_6.png', 'DetailImageFile', 'prod_detail_6.png');
            ];
        end
        
        function coins = getCoins()
            coins = [0.10, 0.20, 0.50, 1.00, 2.00, 5.00];
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
            colors.Button = [0.4 0.4 0.45];    
            colors.ConfirmGreen = [0 0.7 0.3]; 
            colors.Green = [0 1 0];            
            colors.Text = [1 1 1];             
        end
    end
end

