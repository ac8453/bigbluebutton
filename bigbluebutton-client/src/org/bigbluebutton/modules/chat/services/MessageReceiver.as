/**
 * BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
 * 
 * Copyright (c) 2012 BigBlueButton Inc. and by respective authors (see below).
 *
 * This program is free software; you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 3.0 of the License, or (at your option) any later
 * version.
 * 
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along
 * with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
 *
 */
package org.bigbluebutton.modules.chat.services
{
  import flash.events.IEventDispatcher;
  
  import org.as3commons.logging.api.ILogger;
  import org.as3commons.logging.api.getClassLogger;
  import org.bigbluebutton.core.BBB;
  import org.bigbluebutton.core.EventConstants;
  import org.bigbluebutton.core.events.CoreEvent;
  import org.bigbluebutton.core.model.LiveMeeting;
  import org.bigbluebutton.main.model.users.IMessageListener;
  import org.bigbluebutton.modules.chat.events.ClearPublicChatEvent;
  import org.bigbluebutton.modules.chat.model.ChatConversation;
  import org.bigbluebutton.modules.chat.model.ChatModel;
  import org.bigbluebutton.modules.chat.vo.ChatMessageVO;
  
  public class MessageReceiver implements IMessageListener
  {
    
    private static const LOGGER:ILogger = getClassLogger(MessageReceiver);
    
    public var dispatcher:IEventDispatcher;
    
    public function MessageReceiver()
    {
      BBB.initConnectionManager().addMessageListener(this);
    }
    
    public function onMessage(messageName:String, message:Object):void
    {
      switch (messageName) {
        case "SendPublicMessageEvtMsg":
          handleSendPublicMessageEvtMsg(message);
          break;			
        case "SendPrivateMessageEvtMsg":
          handleSendPrivateMessageEvtMsg(message);
          break;	
        case "GetGroupChatMsgsRespMsg":
          handleGetChatHistoryRespMsg(message);
          break;	
        case "ClearPublicChatHistoryEvtMsg":
          handleClearPublicChatHistoryEvtMsg(message);
          break;
        case "GroupChatMessageBroadcastEvtMsg":
          handleGroupChatMessageBroadcastEvtMsg(message);
          break;
        default:
          //   LogUtil.warn("Cannot handle message [" + messageName + "]");
      }
    }
    
    private function handleGetChatHistoryRespMsg(message:Object):void {
      LOGGER.debug("Handling chat history message [{0}]", [message.body.msgs]);
      var rawMessages:Array = message.body.msgs as Array;
      var processedMessages:Array = new Array();
      
      for (var i:int = 0; i < rawMessages.length; i++) {
        processedMessages.push(processNewChatMessage(rawMessages[i] as Object));
      }
      
      var publicChat: ChatConversation = LiveMeeting.inst().chats.getChatConversation(ChatModel.MAIN_PUBLIC_CHAT);
      publicChat.processChatHistory(processedMessages);
      
    }
    
    private function handleGroupChatMessageBroadcastEvtMsg(message: Object):void {
      LOGGER.debug("onMessageFromServer2x - " + message);
      var header: Object = message.header as Object;
      var body: Object = message.body as Object;
      var chatId: String = body.chatId as String;
      
      var msg: ChatMessageVO = processNewChatMessage(body.msg as Object);
      
      var publicChat: ChatConversation = LiveMeeting.inst().chats.getChatConversation(ChatModel.MAIN_PUBLIC_CHAT);
      publicChat.newChatMessage(msg);
      
      var pcCoreEvent:CoreEvent = new CoreEvent(EventConstants.NEW_PUBLIC_CHAT);
      pcCoreEvent.message = message;
      dispatcher.dispatchEvent(pcCoreEvent);
    }
    
    private function handleSendPublicMessageEvtMsg(message:Object, history:Boolean = false):void {
      var msg:ChatMessageVO = processIncomingChatMessage(message.body.message);
      
      var publicChat: ChatConversation = LiveMeeting.inst().chats.getChatConversation(ChatModel.MAIN_PUBLIC_CHAT);
      publicChat.newChatMessage(msg);
      
      var pcCoreEvent:CoreEvent = new CoreEvent(EventConstants.NEW_PUBLIC_CHAT);
      pcCoreEvent.message = message;
      dispatcher.dispatchEvent(pcCoreEvent);
    }
    
    private function handleSendPrivateMessageEvtMsg(message:Object):void {
      var msg:ChatMessageVO = processIncomingChatMessage(message.body.message);
      
      var chatId: String = ChatModel.getConvId(msg.fromUserId, msg.toUserId);
      var privChat: ChatConversation = LiveMeeting.inst().chats.getChatConversation(chatId);
      privChat.newPrivateChatMessage(msg);
      
      var pcCoreEvent:CoreEvent = new CoreEvent(EventConstants.NEW_PRIVATE_CHAT);
      pcCoreEvent.message = message;
      dispatcher.dispatchEvent(pcCoreEvent);      
    }
    
    private function handleClearPublicChatHistoryEvtMsg(message:Object):void {
      LOGGER.debug("Handling clear chat history message");
      
      var publicChat: ChatConversation = LiveMeeting.inst().chats.getChatConversation(ChatModel.MAIN_PUBLIC_CHAT);
      publicChat.clearPublicChat();
      
      var clearChatEvent:ClearPublicChatEvent = new ClearPublicChatEvent(ClearPublicChatEvent.CLEAR_PUBLIC_CHAT_EVENT);
      dispatcher.dispatchEvent(clearChatEvent);
    }
    
    private function processIncomingChatMessage(rawMessage:Object):ChatMessageVO {
      var msg:ChatMessageVO = new ChatMessageVO();
      msg.fromUserId = rawMessage.fromUserId;
      msg.fromUsername = rawMessage.fromUsername;
      msg.fromColor = rawMessage.fromColor;
      msg.fromTime = rawMessage.fromTime;
      msg.fromTimezoneOffset = rawMessage.fromTimezoneOffset;
      msg.toUserId = rawMessage.toUserId;
      msg.toUsername = rawMessage.toUsername;
      msg.message = rawMessage.message;
      return msg;
    }
    
    private function processNewChatMessage(message:Object):ChatMessageVO {
      var msg:ChatMessageVO = new ChatMessageVO();
      msg.fromUserId = message.sender.id as String;
      msg.fromUsername = message.sender.name as String;
      msg.fromColor = message.color as String;
      msg.fromTime = message.timestamp as Number;
      msg.fromTimezoneOffset = message.timestamp as Number;
      msg.toUserId = message.chatId as String;
      msg.toUsername = message.chatId as String;
      msg.message = message.message as String;
      return msg;
    }
  }
}