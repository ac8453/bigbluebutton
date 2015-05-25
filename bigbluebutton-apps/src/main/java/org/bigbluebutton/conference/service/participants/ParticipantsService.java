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

package org.bigbluebutton.conference.service.participants;

import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;
import org.red5.server.api.Red5;
import org.red5.server.api.scope.IScope;

import java.util.Map;

import org.bigbluebutton.conference.BigBlueButtonSession;
import org.bigbluebutton.conference.Constants;
import org.bigbluebutton.core.api.IBigBlueButtonInGW;


public class ParticipantsService {
	private static Logger log = Red5LoggerFactory.getLogger( ParticipantsService.class, "bigbluebutton" );	
	private IBigBlueButtonInGW bbbInGW, red5InGW;
    
	public void assignPresenter(Map<String, String> msg) {
		IScope scope = Red5.getConnectionLocal().getScope();
		String meetingId = scope.getName();
		String newPresenterID = (String) msg.get("newPresenterID");
		String newPresenterName = (String) msg.get("newPresenterName");
		String assignedBy = (String) msg.get("assignedBy");

		bbbInGW.assignPresenter(meetingId, newPresenterID, newPresenterName, assignedBy);
	}
	
	public void getParticipants() {
		IScope scope = Red5.getConnectionLocal().getScope();
		String meetingId = scope.getName();
		String userId = getBbbSession().getInternalUserID();
		bbbInGW.getUsers(meetingId, userId);
	}
	
	public void userRaiseHand() {
		IScope scope = Red5.getConnectionLocal().getScope();
		String userId = getBbbSession().getInternalUserID();
		bbbInGW.userRaiseHand(scope.getName(), userId);
	}
	
	public void lowerHand(Map<String, String> msg) {
		IScope scope = Red5.getConnectionLocal().getScope();
		String meetingId = scope.getName();
		String userId = (String) msg.get("userId");
		String loweredBy = (String) msg.get("loweredBy");

		bbbInGW.lowerHand(meetingId, userId, loweredBy);
	}
	
	public void ejectUserFromMeeting(Map<String, String> msg) {
		IScope scope = Red5.getConnectionLocal().getScope();
		String meetingId = scope.getName();
		String userId = (String) msg.get("userId");
		String ejectedBy = (String) msg.get("ejectedBy");

		bbbInGW.ejectUserFromMeeting(meetingId, userId, ejectedBy);
	}
	
	public void shareWebcam(String stream) {
		IScope scope = Red5.getConnectionLocal().getScope();
		String meetingId = scope.getName();
		String userId = getBbbSession().getInternalUserID();

		bbbInGW.shareWebcam(meetingId, userId, stream);	
	}
	
	public void unshareWebcam(String stream) {
		IScope scope = Red5.getConnectionLocal().getScope();
		String meetingId = scope.getName();
		String userId = getBbbSession().getInternalUserID();

		bbbInGW.unshareWebcam(meetingId, userId, stream);
	}
	
	public void setParticipantStatus(Map<String, Object> msg) {
		IScope scope = Red5.getConnectionLocal().getScope();
		String meetingId = scope.getName();
		String userId = (String) msg.get("userID");
		String status = (String) msg.get("status");
		Object value = (Object) msg.get("value");
		
		bbbInGW.setUserStatus(meetingId, userId, status, value);
	}
		
	public void setRecordingStatus(Map<String, Object> msg) {
		IScope scope = Red5.getConnectionLocal().getScope();
		String meetingId = scope.getName();
		String userId = (String) msg.get("userId");
		Boolean recording = (Boolean) msg.get("recording");

		bbbInGW.setRecordingStatus(meetingId, userId, recording);
	}

	public void getRecordingStatus() {
		IScope scope = Red5.getConnectionLocal().getScope();
		String meetingId = scope.getName();

		bbbInGW.getRecordingStatus(meetingId, getMyUserId());
	}
	
	public String getMyUserId() {
		BigBlueButtonSession bbbSession = (BigBlueButtonSession) Red5.getConnectionLocal().getAttribute(Constants.SESSION);
		assert bbbSession != null;
		return bbbSession.getInternalUserID();
	}
	
	private BigBlueButtonSession getBbbSession() {
        return (BigBlueButtonSession) Red5.getConnectionLocal().getAttribute(Constants.SESSION);
    }

	public void setBigBlueButtonInGW(IBigBlueButtonInGW bbbGW) {
		this.bbbInGW = bbbGW;
	}

	public void setRed5InGW(IBigBlueButtonInGW red5InGW) {
		this.red5InGW = red5InGW;
	}
}
