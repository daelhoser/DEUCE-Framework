//
//  ConversationCellViewModel.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 9/1/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework

final class ConversationCellViewModel<Image> {
    typealias Observer<T> = (T) -> Void

    private let model: Conversation
    private let imageDataLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    private var imageTransformer: (Data) -> Image?

    init(model: Conversation, imageDataLoader: ImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageDataLoader = imageDataLoader
        self.imageTransformer = imageTransformer
    }

    var conversationID: UUID {
        return model.conversationId
    }

    var userGroupName: String? {
        return model.lastMessageUser ?? model.groupName
    }

    var message: String? {
        return model.message
    }

    var initials: String? {
        guard let fullName = userGroupName else { return nil }

        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated
        guard let personNameComponents = formatter.personNameComponents(from: fullName) else {
            return nil
        }

        return formatter.string(from: personNameComponents)
    }

    var lastMessageTime: String? {
        return model.lastMessageTime?.elapsedInterval
    }

    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    func loadImageData() {
        guard let url = model.image else { return }

        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)

        task = imageDataLoader.loadImageData(from: url) { [weak self] result in
            guard let self = self else { return }

            let data = try? result.get()

            if let image = data.flatMap( self.imageTransformer) {
                self.onImageLoad?(image)
            } else {
                self.onShouldRetryImageLoadStateChange?(true)
            }
            self.onImageLoadingStateChange?(false)
        }
    }

    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
