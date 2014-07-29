//
//  PNMessageChannelDelegate.h
//  pubnub
//
//  Describes interface which is used to organize
//  communication between service communication
//  channel and PubNub client
//
//
//  Created by Sergey Mamontov on 12/29/12.
//
//


#pragma mark Class forward

@class PNObjectSynchronizationEvent, PNAccessRightsCollection, PNServiceChannel, PNMessagesHistory, PNWhereNow;
@class PNResponse, PNHereNow, PNClient;


@protocol PNServiceChannelDelegate<NSObject>


@required

/**
 Sent to the delegate when \b PubNub client successfully retrieved state for client.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param client
 \b PNClient instance which hold information on for who this response and state for him on concrete channel.
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReceiveClientState:(PNClient *)client;

/**
 Sent to the delegate when \b PubNub client did fail to retrieve state for client.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param error
 \b PNError instance which holds information about what went wrong and why request failed. \a 'error.associatedObject'
 contains reference on \b PNClient instance which will allow to review for whom request has been made.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)serviceChannel:(PNServiceChannel *)channel clientStateReceiveDidFailWithError:(PNError *)error;

/**
 Sent to the delegate when \b PubNub client successfully updated state for client.
 
 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.
 
 @param client
 \b PNClient instance which hold information on for who this response and updated state on concrete channel.
 */
- (void)serviceChannel:(PNServiceChannel *)channel didUpdateClientState:(PNClient *)client;

/**
 Sent to the delegate when \b PubNub client did fail to update state for client.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param error
 \b PNError instance which holds information about what went wrong and why request failed. \a 'error.associatedObject'
 contains reference on \b PNClient instance which will allow to review for whom request has been made.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)serviceChannel:(PNServiceChannel *)channel clientStateUpdateDidFailWithError:(PNError *)error;

/**
 Sent to the delegate when \b PubNub client successfully received whole object from \b PubNub cloud.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param information
 \b PNObjectFetchInformation instance which store information about object which has been requested from the cloud.

 @param event
 Remote object payload information which has been received during synchronization with cloud.
 */
- (void)serviceChannel:(PNServiceChannel *)channel didFetchObject:(PNObjectFetchInformation *)information
                  data:(PNObjectSynchronizationEvent *)event;

/**
 Sent to the delegate when \b PubNub client successfully received only portion of the object from \b PubNub cloud. This
 event mostly will be triggered when

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param information
 \b PNObjectFetchInformation instance which store information about object which has been requested from the cloud.

 @param partialObjectData
 Portion of the data retrieved from \b PubNub cloud.

 @param event
 Remote object payload information which has been received during synchronization with cloud.
 */
- (void)serviceChannel:(PNServiceChannel *)channel didFetchPartOfTheObject:(PNObjectFetchInformation *)information
           partialData:(PNObjectSynchronizationEvent *)event nextPortionToken:(NSString *)nextObjectDataPortionToken;

/**
 Sent to the delegate when \b PubNub client did fail to receive remote object from cloud.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param error
 \b PNError instance which holds information about what went wrong and why request failed. \a 'error.associatedObject'
 contains reference on \b PNObjectModificationInformation instance which represent information as for object for which
 client were unable to fetch remote object.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)serviceChannel:(PNServiceChannel *)channel objectFetchDidFailWithError:(PNError *)error;

/**
 Sent to the delegate when \b PubNub client successfully updated remote object information using data object with
 description.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param information
 Reference on object which store all required information to update remote object.
 */
- (void)serviceChannel:(PNServiceChannel *)channel didUpdateObjectWithInformation:(PNObjectModificationInformation *)information;

/**
 Sent to the delegate when \b PubNub client did fail to update remote object data.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param error
 \b PNError instance which holds information about what went wrong and why request failed. \a 'error.associatedObject'
 contains reference on \b PNObjectModificationInformation instance which represent information as for object for which
 client were unable to update remote object.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)serviceChannel:(PNServiceChannel *)channel objectUpdateDidFailWithError:(PNError *)error;

/**
 Sent to the delegate when \b PubNub client successfully replaced remote object information using data object with
 description.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param information
 Reference on object which store all required information to replace remote object data.
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReplaceObjectWithInformation:(PNObjectModificationInformation *)information;

/**
 Sent to the delegate when \b PubNub client did fail to replace remote object data.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param error
 \b PNError instance which holds information about what went wrong and why request failed. \a 'error.associatedObject'
 contains reference on \b PNObjectModificationInformation instance which represent information as for object for which
 client were unable to replace remote object.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)serviceChannel:(PNServiceChannel *)channel objectReplaceDidFailWithError:(PNError *)error;

/**
 Sent to the delegate when \b PubNub client successfully delete remote object information using data object with
 description.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param information
 Reference on object which store all required information to delete remote object data.
 */
- (void)serviceChannel:(PNServiceChannel *)channel didDeleteObjectWithInformation:(PNObjectModificationInformation *)information;

/**
 Sent to the delegate when \b PubNub client did fail to delete remote object data.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param error
 \b PNError instance which holds information about what went wrong and why request failed. \a 'error.associatedObject'
 contains reference on \b PNObjectModificationInformation instance which represent information as for object for which
 client were unable to delete remote object.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)serviceChannel:(PNServiceChannel *)channel objectDeleteDidFailWithError:(PNError *)error;

/**
 Sent to the delegate when \b PubNub client successfully changed access rights.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param accessRightsInformation
 Instance of \b PNAccessRightsCollection which aggregate in itself \b PNAccessRightsInformation instances to describe
 access rights at different levels (there is a three levels: application, channel and user).
 */
- (void)serviceChannel:(PNServiceChannel *)channel didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection;

/**
 Sent to the delegate when \b PubNub client failed to change access rights.

 @param client
 \b PubNub client which failed request processing (this is singleton).

 @param error
 \b PNError instance which holds information about what went wrong and why request failed. \a 'error.associatedObject'
 contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)serviceChannel:(PNServiceChannel *)channel accessRightsChangeDidFailWithError:(PNError *)error;

/**
 Sent to the delegate when \b PubNub client successfully retrieved access rights information for specified object.

 @param channel
 Communication channel over which request has been sent and processed response from \b PubNub services.

 @param accessRightsInformation
 Instance of \b PNAccessRightsCollection which aggregate in itself \b PNAccessRightsInformation instances to describe
 access rights at different levels (there is a three levels: application, channel and user).
 */
- (void)serviceChannel:(PNServiceChannel *)channel didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection;

/**
 Sent to the delegate when \b PubNub client failed to audit access rights.

 @param client
 \b PubNub client which failed request processing (this is singleton).

 @param error
 \b PNError instance which holds information about what went wrong and why request failed. \a 'error.associatedObject'
 contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b
 PubNub client used for audition.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)serviceChannel:(PNServiceChannel *)channel accessRightsAuditDidFailWithError:(PNError *)error;

/**
 * Sent to the delegate when time token arrived
 * from backend by request
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReceiveTimeToken:(NSNumber *)timeToken;

/**
 * Sent to the delegate when some error occurred
 * while tried to process time token retrieve request
 */
- (void)serviceChannel:(PNServiceChannel *)channel receiveTimeTokenDidFailWithError:(PNError *)error;

/**
 * Sent to the delegate when push notification successfully
 * enabled on specified channels
 */
- (void)serviceChannel:(PNServiceChannel *)channel didEnablePushNotificationsOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when push notification enabling failed
 * because of error
 */
- (void)                  serviceChannel:(PNServiceChannel *)channel
didFailPushNotificationEnableForChannels:(NSArray *)channels
                               withError:(PNError *)error;

/**
 * Sent to the delegate when push notification successfully
 * disabled on specified channels
 */
- (void)serviceChannel:(PNServiceChannel *)channel didDisablePushNotificationsOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when push notification disabling failed
 * because of error
 */
- (void)                   serviceChannel:(PNServiceChannel *)channel
didFailPushNotificationDisableForChannels:(NSArray *)channels
                                withError:(PNError *)error;

/**
 * Sent to the delegate when push notifications succeffully removed
 * from all channels
 */
- (void)serviceChannelDidRemovePushNotifications:(PNServiceChannel *)channel;

/**
 * Sent to the delegate when push notification removal failed because of error
 */
- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationsRemoveWithError:(PNError *)error;

/**
 * Sent to the delegate when push notifications enabled channels
 * successfully received
 */
- (void)serviceChannel:(PNServiceChannel *)channel didReceivePushNotificationsEnabledChannels:(NSArray *)channels;

/**
 * Sent to the delegate when push notification enabled channels
 * retrieval failed
 */
- (void)serviceChannel:(PNServiceChannel *)channel didFailPushNotificationEnabledChannelsReceiveWithError:(PNError *)error;

/**
 * Sent to the delegate when latency meter information
 * arrived from backend
 */
- (void)  serviceChannel:(PNServiceChannel *)channel
didReceiveNetworkLatency:(double)latency
     andNetworkBandwidth:(double)bandwidth;


/**
 * Sent to the delegate right before message post
 * request will be sent to the PubNub service
 */
- (void)serviceChannel:(PNServiceChannel *)channel willSendMessage:(PNMessage *)message;

/**
 * Sent to the delegate when PubNub service responded
 * that message has been processed
 */
- (void)serviceChannel:(PNServiceChannel *)channel didSendMessage:(PNMessage *)message;

/**
 * Sent to the delegate if PubNub reported with processing error or message was unable to send because of some other
 * issues.
 */
- (void)serviceChannel:(PNServiceChannel *)channel didFailMessageSend:(PNMessage *)message withError:(PNError *)error;

/**
 * Sent to the delegate when PubNub service responded on history download request.
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveMessagesHistory:(PNMessagesHistory *)history;

/**
 * Sent to the delegate when PubNub service refused to return history for specified channel.
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailHisoryDownloadForChannel:(PNChannel *)channel
             withError:(PNError *)error;

/**
 * Sent to the delegate when PubNub service responded on participants list request.
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantsList:(PNHereNow *)participants;

/**
 * Sent to the delegate when PubNub service failed to retrieve participants list for specified channel
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailParticipantsListLoadForChannel:(PNChannel *)channel
             withError:(PNError *)error;

/**
 Sent to the delegate when PubNub service responded on participant channels list request.

 @param serviceChannel
 \b PNServiceChannel instance which triggered event.

 @param participantChannels
 \b PNWhereNow instance which hold information about channels and client identifier for which they has been requested.

 @since 3.6.0
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantChannelsList:(PNWhereNow *)participantChannels;

/**
 Sent to the delegate when PubNub service failed to retrieve participants list for specified channel.

 @param serviceChannel
 \b PNServiceChannel instance which triggered event.

 @param clientIdentifier
 Identifier for which channels list has been requested,

 @param error
 \b PNError instance which allow to understand why request failed.

 @since 3.6.0
 */
- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailParticipantChannelsListLoadForIdentifier:(NSString *)clientIdentifier
             withError:(PNError *)error;

@end
