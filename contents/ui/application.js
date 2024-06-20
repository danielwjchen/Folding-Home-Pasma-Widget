const baseUrl = "http://127.0.0.1:7396/api";
const TIMEOUT = 1000;

function fetch(resource) {
	const url = (typeof resource === "string") ? resource : resource.url;
	const method = resource.method || "GET";
	return new Promise((resolve, reject) => {
		const request = new XMLHttpRequest();
		if (resource.headers) {
			Object.entries(resource).forEach(([key, value]) => {
				request.setRequestHeader(key, value);
			});
		}
		request.onreadystatechange = () => {
			if (request.readyState === XMLHttpRequest.DONE) {
				const response = {
					status: request.status,
					headers: request.getAllResponseHeaders(),
					contentType: request.responseType,
					content: request.response,
				};
				resolve(response);
			}
		}
		request.ontimeout = (event) => {
			reject(event);
		};
		request.onabort = (event) => {
			reject(event);
		};
		request.onerror = (event) => {
			reject(event);
		};
		request.open(method, url);
		request.send();
	});
}

function getUrl(path, queryParams) {
	const result = `${baseUrl}/${path}`;
	if (queryParams) {
		const queryStrings = Object.entries(queryParams).map(([key, value]) => {
			return `${key}=${encodeURI(value)}`;
		});
		return `${result}?${queryStrings.join("&")}`;
	}
	return result;

}

function createSession() {
	const resource = {
		url: getUrl("session", { "_": Math.random() }),
		method: "PUT"
	};
	return new Promise((resolve, reject) => {

		fetch(resource).then(response => {
			Promise.all([
				fetch({
					url: getUrl("updates/set", {
						sid: response.content,
						update_id: 0,
						update_rate: 1,
						update_path: '/api/basic'
					}),
				}),
				fetch({
					url: getUrl("updates/set", {
						sid: response.content,
						update_id: 1,
						update_rate: 1,
						update_path: '/api/slots'
					}),
				})
			]).then(() => {
				// intentionally left blank
			}).catch(reason => {
				reject(reason);
			});
			resolve(response)
		})
	});

}

function getUpdates(timer, sid, callback) {
	const resource = {
		url: getUrl("updates", { sid: sid }),
	};
	fetch(resource).then((response) => {
		response.json = JSON.parse(response.content);
		callback(response);
		timer.setTimeout(() => {
			getUpdates(timer, sid, callback)
		}, TIMEOUT);
	}).catch(reason => {
		console.debug(reason);
	});
}

function toggleIsOnlyWhenIdle(sid, isOnlyWhenIdle) {
	const resource = {
		url: getUrl("set", { sid: sid, idle: isOnlyWhenIdle }),
	};
	fetch(resource).then(() => {
		// intentionally left blank
	}).catch(reason => {
		console.debug(reason);
	});
}

function toggleStopsAfterFinishingCurrentWorkUnit(sid, stopsAfterFinishingCurrentWorkUnit) {
	const resource = {
		url: getUrl("set", { sid: sid, finish: stopsAfterFinishingCurrentWorkUnit }),
	};
	fetch(resource).then(() => {
		// intentionally left blank
	}).catch(reason => {
		console.debug(reason);
	});
}