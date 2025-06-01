//
//  CardView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 20/05/25.
//

import SwiftUI

struct CardView: View {
    var card : Card
    var body: some View {
        
        VStack{
            
            Text(card.title)
                .font(.system(size: 40))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(card.description)
                .font(.system(size: 17))
                .multilineTextAlignment(.center)
                .frame(width: 335,height: 100)
                .fontWeight(.light)
                .foregroundColor(.white)
                .padding()
            
        }.padding()
            .offset(x: 0,y: 250)
    }
}

#Preview {
    CardView(card: testData[0]).preferredColorScheme(.dark)
}
